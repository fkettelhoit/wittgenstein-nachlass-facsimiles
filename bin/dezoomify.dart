import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:html/parser.dart' as html;
import 'package:pool/pool.dart';

final _wittgensteinSource = 'http://www.wittgensteinsource.org';

final _bergenNachlassEdition = '/agora_show_collection_list/1?customMenu=1';

void main(List<String> args) async {
  final maxWidth = args.isNotEmpty ? int.tryParse(args[0]) : null;
  final dest = args.length > 1 ? io.Directory(args[1]) : null;
  print('Fetching document names from wittgensteinsource.org...');
  final docs = await _fetchPages();
  final pool = Pool(50, timeout: Duration(minutes: 1));
  await for (final facsimiles in docs) {
    if (facsimiles.isNotEmpty) {
      final xml = facsimiles.first.split(',')[0];
      final pages = facsimiles.map((p) => p.split(',')[1]);
      await Future.wait(
          _dezoomify(xml, pages, pool, maxWidth: maxWidth, dest: dest));
    }
  }
}

Stream<Iterable<String>> _fetchPages() async* {
  final docs = await _fetchDocumentLinks(_bergenNachlassEdition);
  for (final doc in docs) {
    yield await _fetchPagesForDoc(doc);
  }
}

Future<List<String>> _fetchPagesForDoc(String url) async {
  final fetched = await _fetchHtml('$_wittgensteinSource$url');
  final doc = html.parse(fetched);
  return doc
      .getElementsByTagName('a')
      .map((a) => a.attributes['data-title'])
      .where((dataTitle) => dataTitle != null)
      .toList();
}

Future<List<String>> _fetchDocumentLinks(String url) async {
  final fetched = await _fetchHtml('$_wittgensteinSource$url');
  final doc = html.parse(fetched);
  return doc
      .getElementsByTagName('li')
      .where((li) => li.text.contains('(WL)'))
      .map((li) => li
          .getElementsByTagName('a')
          .where((a) => a.text == 'F')
          .map((a) => a.attributes['href']))
      .expand((x) => x)
      .toList();
}

Future<String> _fetchHtml(String uri) => io.HttpClient()
    .getUrl(Uri.parse(uri))
    .then((request) => request.close())
    .then<String>(_readResponse);

Future<String> _readResponse(io.HttpClientResponse response) {
  final completer = Completer<String>();
  final contents = StringBuffer();
  response.transform(utf8.decoder).listen(contents.write,
      onDone: () => completer.complete(contents.toString()));
  return completer.future;
}

Iterable<Future<io.ProcessResult>> _dezoomify(
    String xml, Iterable<String> pages, Pool pool,
    {int maxWidth, io.Directory dest}) sync* {
  maxWidth ??= 2000;
  dest ??= io.Directory('facsimiles/');
  dest.createSync();
  print('********** $xml ***********');
  io.Directory('${dest.path}/$xml').createSync();
  for (final page in pages) {
    final out = '${dest.path}/$xml/$page.png';
    if (io.File(out).existsSync()) continue;

    final doc = xml == 'Ts-309' ? 'Ts-309-Stonborough' : xml;
    final dzi = 'http://www.wittgensteinsource.org/fcgi-bin/iipsrv.fcgi'
        '?DeepZoom=/var/www/wab/web/uploads/flexip_viewer_images/iip/'
        '$doc,$page.tif.dzi';

    final tmp = '$out-tmp.png';
    Future<io.ProcessResult> p() => io.Process.run('dezoomify-rs', [
          '--max-width',
          maxWidth.toString(),
          '--retries',
          '2',
          '--timeout',
          '60s',
          dzi,
          tmp
        ]).then((results) {
          final tmpFile = io.File(tmp);
          if (tmpFile.existsSync() && results.stderr.toString().isEmpty) {
            tmpFile.renameSync(out);
          } else {
            print('Aborting download of file $tmp:\n${results.stderr}\n');
          }
          return results;
        });
    yield pool.withResource(p);
  }
}

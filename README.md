# Wittgenstein's Nachlass Facsimiles

This repository allows you to download all the facsimiles of Wittgenstein's
Nachlass that are kept in the Wren Library and released under a
[Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/).

> CC BY-NC 4.0. Original at the Wren Library, Trinity College, Cambridge, where
> in 2014-15, on the request of the Wittgenstein Archives at the University of
> Bergen (WAB) and with the generous financial support of the Stanhill
> Foundation, London, this scan was produced. The image was post-processed at
> WAB and is reproduced here by permission of The Master and Fellows of Trinity
> College, Cambridge, and the University of Bergen, Bergen. The sale, further
> reproduction or use of this image for commercial purposes without prior
> permission from the copyright holder is prohibited. © 2015 The Master and
> Fellows of Trinity College, Cambridge; The University of Bergen, Bergen

For more details, see http://www.wittgensteinsource.org

Please note that while the software used to fetch the facsimiles is released
under the MIT license, the facsimile files are released under a Creative
Commons license (see [facsimiles/LICENSE](facsimiles/LICENSE)).

For demonstration purposes, the result of downloading Ms-101 with a maximum
width of 2000 px is included in the [facsimiles](facsimiles/) directory.

## How to run locally

If you want to download all the images yourself, you need to install
[dezoomify-rs](https://github.com/lovasoa/dezoomify-rs), add it to your
`$PATH`, install Dart and run `pub get && pub run bin/dezoomify.dart`. At the
moment, the script is deliberately hardcoded to only download facsimiles kept
in the Wren Library (as only these facsimiles are released under a CC BY-NC
license) and to fetch the zoom level with a maximum width of 2000 px.

If you want to download images with a different resolution or to a different
location, you can pass the maximum width and the download destination as
command line arguments:

```
pub run bin/dezoomify.dart 5000 path/to/my/directory
```
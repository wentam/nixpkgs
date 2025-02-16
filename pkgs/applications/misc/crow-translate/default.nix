{ lib
, stdenv
, fetchzip
, substituteAll
, cmake
, extra-cmake-modules
, qttools
, kwayland
, leptonica
, tesseract4
, qtmultimedia
, qtx11extras
, qttranslations
, wrapQtAppsHook
, gst_all_1
, testers
, crow-translate
}:

stdenv.mkDerivation rec {
  pname = "crow-translate";
  version = "2.10.0";

  src = fetchzip {
    url = "https://github.com/${pname}/${pname}/releases/download/${version}/${pname}-${version}-source.tar.gz";
    hash = "sha256-ayEt4PI15NjlmFrDEa6Ipbn94nN9Ga7jThnIVBWPgKw=";
  };

  patches = [
    (substituteAll {
      # See https://github.com/NixOS/nixpkgs/issues/86054
      src = ./fix-qttranslations-path.patch;
      inherit qttranslations;
    })
  ];

  postPatch = ''
    substituteInPlace data/io.crow_translate.CrowTranslate.desktop \
      --replace "Exec=qdbus" "Exec=${lib.getBin qttools}/bin/qdbus"
  '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    kwayland
    leptonica
    tesseract4
    qtmultimedia
    qtx11extras
  ] ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  preFixup = ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  passthru.tests.version = testers.testVersion {
    package = crow-translate;
  };

  meta = with lib; {
    description = "A simple and lightweight translator that allows to translate and speak text using Google, Yandex and Bing";
    homepage = "https://crow-translate.github.io/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
    mainProgram = "crow";
  };
}

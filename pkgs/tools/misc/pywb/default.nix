{ lib, fetchFromGitHub, python39 }:

with lib;

let
  python = python39.override {
    # Required by pywb.
    packageOverrides = self: super: {
      jinja2 = super.jinja2.overridePythonAttrs (old: rec {
        version = "2.11.3";
        src = old.src.override {
          inherit version;
          sha256 = "a6d58433de0ae800347cab1fa3043cebbabe8baa9d29e668f1c768cb87a333c6";
        };
      });
      click = super.click.overridePythonAttrs (old: rec {
        version = "7.1.2";
        src = old.src.override {
          inherit version;
          sha256 = "d2b5255c7c6349bc1bd1e59e08cd12acbbd63ce649f2588755783aa94dfb6b1a";
        };
      });
      itsdangerous = super.itsdangerous.overridePythonAttrs (old: rec {
        version = "1.1.0";
        src = old.src.override {
          inherit version;
          sha256 = "321b033d07f2a4136d3ec762eac9f16a10ccd60f53c0c91af90217ace7ba1f19";
        };
      });
      markupsafe = super.markupsafe.overridePythonAttrs (old: rec {
        version = "2.0.1";
        src = old.src.override {
          inherit version;
          sha256 = "sha256-WUxngH+xYjizDES99082wCzfItHIzake+KDtjav1Ygo=";
        };
      });
      flask = super.flask.overridePythonAttrs (old: rec {
        version = "1.1.4";
        src = old.src.override {
          inherit version;
          sha256 = "0fbeb6180d383a9186d0d6ed954e0042ad9f18e0e8de088b2b419d526927d196";
        };
      });
      werkzeug = super.werkzeug.overridePythonAttrs (old: rec {
        version = "1.0.1";
        src = old.src.override {
          inherit version;
          sha256 = "6c80b1e5ad3665290ea39320b91e1be1e0d5f60652b964a3070216de83d2e47c";
        };
        checkInputs = old.checkInputs ++ (with self; [
          requests
        ]);
        disabledTests = old.disabledTests ++ [
          # ResourceWarning: unclosed file
          "test_basic"
          "test_date_to_unix"
          "test_easteregg"
          "test_file_rfc2231_filename_continuations"
          "test_find_terminator"
          "test_save_to_pathlib_dst"
        ];
        disabledTestPaths = old.disabledTestPaths ++ [
          # ResourceWarning: unclosed file
          "tests/test_http.py"
          "tests/test_local.py"
        ];
      });
    };
  };
in
python.pkgs.buildPythonApplication rec {
  name = "pywb";
  version = "2.6.8";

  src = fetchFromGitHub {
    owner = "webrecorder";
    repo = "pywb";
    rev = "v-${version}";
    sha256 = "sha256-82m1+9NyujWWlfd5Ip6mVhlvvS93dkFBX2WTtmXxIcg=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = with python.pkgs; [
    brotlipy
    chardet
    fakeredis
    gevent
    jinja2
    markupsafe
    portalocker
    py3amf
    pytest
    python-dateutil
    pyyaml
    redis
    requests
    six
    surt
    ua-parser
    warcio
    webassets
    webencodings
    werkzeug
    wsgiprox
  ];

  postPatch = ''
    substituteInPlace requirements.txt \
       --replace "redis<3.0" "redis" \
       --replace "fakeredis<1.0" "fakeredis" \
  '';

  doCheck = false;

  meta = {
    description = "Python web archiving toolkit for creating and replaying web archives";
    homepage = https://github.com/webrecorder/pywb;
    license = licenses.gpl3;
    maintainers = with maintainers; [ anpandey ];
    platforms = platforms.all;
  };
}

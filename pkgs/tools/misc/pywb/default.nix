{ lib, fetchFromGitHub, python39, stdenv }:

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
      flask-limiter = super.flask-limiter.overridePythonAttrs (old: rec {
        version = "1.4";
        src = fetchFromGitHub {
          owner = "alisaifee";
          repo = "flask-limiter";
          rev = "1.4";
          sha256 = "sha256-btnJmRnF9dEzkEbLp2gCni1/S2l7yUbbZTemYHlLOGE=";
        };
        checkInputs = with self; [
          pytestCheckHook
          hiro
          mock
          redis
          flask-restful
          pymemcache
        ];
        disabledTests = [
          "test_fallback_to_memory"
          "test_reset_unsupported"
          "test_constructor_arguments_over_config"
          "test_fallback_to_memory_config"
          "test_fallback_to_memory_backoff_check"
          "test_fallback_to_memory_with_global_override"
          "test_custom_key_prefix"
          "test_redis_request_slower_than_fixed_window"
          "test_redis_request_slower_than_moving_window"
          "test_custom_key_prefix_with_headers"
        ];
        disabledTestPaths = [ ];
      });
      fakeredis = super.fakeredis.overridePythonAttrs (old: rec {
        version = "0.16.0" ;
        src = super.fetchPypi {
          pname = "fakeredis";
          inherit version;
          sha256 = "sha256-uoqCAgO6Wnp+9i42GTGNUTuH9gMoxVg2NN85iuS3rwA=";
        };
        checkInputs = old.checkInputs ++ (with self; [
          nose
          lupa
        ]);
        disabledTests = [
          # We're patching this so it never fails.
          "test_searches_for_c_stdlib_and_raises_if_missing"

          "test_append"
          "test_decr"
        ];
        # See https://github.com/NixOS/nixpkgs/issues/7307.
        patchPhase = let
          ext = stdenv.hostPlatform.extensions.sharedLibrary;
        in
          ''substituteInPlace fakeredis.py --replace \
            "find_library('c')" "'${stdenv.cc.libc}/lib/libc${ext}.6'"
        '';
      });
      redis = super.redis.overridePythonAttrs (old: rec {
        version = "2.10.6";
        src = old.src.override {
          inherit version;
          sha256 = "sha256-oiypk86ili27WI+fMNABWsSvzEW+4n05eMDb6el8bA8=";
        };
        pythonImportsCheck = [ ];
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
    sha256 = "sha256-+f0DLTjVZk/A3j02RRHzSgV1ozqUG3pg+cEqyTFc5ms=";
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

  checkInputs = with python.pkgs; [
    pytest
    mock
    webtest
    urllib3
    httpbin
    flask
    ujson
    lxml
    fakeredis
  ];

  testExpression = optionalString (disabledTests != [])
    "-k 'not ${concatStringsSep " and not " disabledTests}'";

  checkPhase = ''
    py.test tests/ ${testExpression}
  '';

  disabledTests = [
    # 400 Bad Request.
    "test_integration"
    "test_live_rewriter"
    "test_redirect_classic"
    "test_socks"
    "test_cert_req"
    "test_force_https"
  ];

  meta = {
    description = "Python web archiving toolkit for creating and replaying web archives";
    homepage = https://github.com/webrecorder/pywb;
    license = licenses.gpl3;
    maintainers = with maintainers; [ anpandey ];
    platforms = platforms.all;
  };
}

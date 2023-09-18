{ lib, fetchFromGitHub, fetchPypi, python3, stdenv }:

let
  python = python3.override {
    # TODO: delete this if we end up not needing any overrides.
    packageOverrides = self: super: {
    };
  };
in
python3.pkgs.buildPythonApplication rec {
  name = "pywb";
  version = "2.7.4";

  src = fetchFromGitHub {
    owner = "webrecorder";
    repo = "pywb";
    rev = "v-${version}";
    sha256 = "sha256-M44TwBzXuF33HNLB2OjmBKNDG9kt/qhGEOu589YGvsQ=";
    fetchSubmodules = true;
  };

  patches = [ ./pywb.patch ];

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "jinja2<3.0.0" "jinja2" \
      --replace "redis<3.0" "redis" \
      --replace "markupsafe<2.1.0" "markupsafe" \
      --replace "fakeredis<1.0" "fakeredis" \
      --replace "gevent==21.12.0" "gevent"
  '';

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

  nativeCheckInputs = with python.pkgs; [
    pytestCheckHook
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

  doCheck = true;

  disabledTests = [
    # 400 Bad Request.
    "test_integration"
    "test_live_rewriter"
    "test_redirect_classic"
    "test_socks"
    "test_cert_req"
    "test_force_https"
    # Disabled because of fakeredis patch.
    "test_single_redis_entry"
    "test_single_warc_record"
    "test_redis_pending_count"
  ];

  meta = {
    description = "Python web archiving toolkit for creating and replaying web archives";
    homepage = "https://github.com/webrecorder/pywb";
    license = with lib.licenses; [ gpl3Plus agpl3Only ];
    maintainers = with lib.maintainers; [ anpandey ];
    platforms = lib.platforms.all;
  };
}

# btop con los fixes de memoria de macOS que upstream todavía no mergeó.
#
# Es la fórmula de homebrew-core (v1.4.8) apuntando a la rama `mac` del fork
# alejlatorre/btop, que hoy es v1.4.8 + aristocratos/btop#1801 (la memoria
# comprimida tiene su propia fila) + un commit propio: "Used" se calcula como
# Monitor de Actividad, total − libre − archivos en caché. Sin eso, en una Mac
# con el swap lleno btop marca la mitad de la RAM que usa Monitor de Actividad,
# y con #1801 solo, ~4 GiB menos.
#
# Se instala con el nombre completo (alejlatorre/tap/btop). Comparte la carpeta
# del Cellar con el btop de homebrew-core, así que hay que desinstalar ese
# primero. El día que upstream mergee el fix, se borra esta fórmula y se vuelve
# al btop de siempre.
class Btop < Formula
  desc "Resource monitor (fork con la memoria usada de macOS como Monitor de Actividad)"
  homepage "https://github.com/alejlatorre/btop/tree/mac"
  url "https://github.com/alejlatorre/btop/archive/refs/tags/v1.4.8-mac.2.tar.gz"
  version "1.4.8-mac.2"
  sha256 "11e76fb3c9157d168624e01af5b9ce34b4da7763fe1e141d1886c324cbb356a9"
  license "Apache-2.0"
  head "https://github.com/alejlatorre/btop.git", branch: "mac"

  depends_on "lowdown" => :build
  # El fix es solo de macOS: en Linux btop ya mide bien, va el de homebrew-core.
  depends_on :macos

  on_macos do
    depends_on "coreutils" => :build
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1600
  end

  fails_with :clang do
    build 1600
    cause "Requires C++23 support for `std::ranges::to`"
  end

  def install
    # El Makefile usa un job por core. THREADS deja que HOMEBREW_MAKE_JOBS lo
    # baje en una máquina con poca RAM libre.
    system "make", "CXX=#{ENV.cxx}", "STRIP=true", "THREADS=#{ENV.make_jobs}"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    assert_path_exists man1/"btop.1"

    require "pty"
    require "io/console"

    config = (testpath/".config/btop")
    mkdir config/"themes"
    begin
      (config/"btop.conf").write <<~EOS
        #? Config file for btop v. #{version}

        update_ms=2000
        log_level=DEBUG
      EOS

      r, w, pid = PTY.spawn(bin/"btop", "--force-utf")
      r.winsize = [80, 130]
      sleep 5
      w.write "q"
    rescue Errno::EIO
      # Apple silicon raises EIO
    end

    log = (testpath/".local/state/btop.log").read
    log = log.lines.grep_v(/ERROR:.* SMC /).join if Hardware::CPU.virtualized?
    assert_match "===> btop++ v", log
    refute_match(/ERROR:/, log)
  ensure
    Process.kill("TERM", pid)
  end
end

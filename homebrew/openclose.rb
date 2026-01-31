class Openclose < Formula
  desc "CLI tool for organizing software specifications and PRDs"
  homepage "https://github.com/bpingris/openclose"
  url "https://github.com/bpingris/openclose.git",
      tag:      "v0.1.0",
      revision: "TODO_INSERT_REVISION_HERE"
  license "MIT"
  head "https://github.com/bpingris/openclose.git", branch: "main"

  depends_on "odin" => :build

  def install
    mkdir_p "build"
    system "odin", "build", "src", "-out:build/openclose", "-o:speed"
    bin.install "build/openclose"
  end

  test do
    assert_match "openclose - CLI tool for organizing specs and PRDs",
                 shell_output("#{bin}/openclose help")
    
    # Test init command creates the expected directory structure
    mkdir "test_init" do
      system "#{bin}/openclose", "init"
      assert_path_exists ".openclose"
      assert_path_exists ".openclose/AGENTS.md"
    end
  end
end

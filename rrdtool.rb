class RrdTool
  PATHS = [
    "/usr/bin",
    "/usr/local/bin",
    "/opt/local/bin"
  ]

  def self.run(path)
    system(command(path))
  end

  def self.command(path)
    "#{binary_path} #{path}"
  end

  def self.binary_path
    @binary_path ||= PATHS.map { |path| Pathname.new(path).join("rrdtool") }.find_all(&:file?).first
  end
end
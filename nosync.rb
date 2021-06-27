#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'

def top_level_paths(paths)
  paths.reject { |child_path|
    child_path.dirname.ascend.any? { |parent_path| paths.include?(parent_path) }
  }
end

# Choose all synced paths, including Desktop and Documents, if enabled.
cloud_docs = Pathname('~/Library/Mobile Documents/com~apple~CloudDocs').expand_path.glob('{,Desktop,Documents}')

bundles = cloud_docs.flat_map { |path| path.glob('**/Gemfile') }
  .flat_map { |path| path.dirname.glob('vendor/bundle') }

cargo_targets = cloud_docs.flat_map { |path| path.glob('**/Cargo.toml') }
  .flat_map { |path| path.dirname.glob('target') }

node_modules = cloud_docs.flat_map { |path| path.glob('**/node_modules') }

venvs = cloud_docs.flat_map { |path| path.glob('**/pyvenv.cfg') }
  .map { |path| path.dirname }

# Only use top-level paths as `.nosync` paths, since e.g. `node_modules`
# may contain other `node_modules` directories as child paths.
nosync_paths = top_level_paths(bundles + cargo_targets + node_modules + venvs)

nosync_paths.each do |path|
  next if path.extname == '.nosync'

  nosync_path = path.dirname/"#{path.basename}.nosync"

  if path.symlink?
    link_path = path.dirname/path.readlink
    if link_path.extname == '.nosync' && !link_path.exist?
      puts "mkdir #{link_path}"
      link_path.mkpath
    end
  elsif path.directory?
    puts "mv #{path} #{nosync_path}"
    path.rename(nosync_path)
    puts "ln -s #{nosync_path.basename} #{path}"
    path.make_symlink(nosync_path.basename)
  end
end

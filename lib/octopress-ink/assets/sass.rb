module Octopress
  module Ink
    module Assets
      class Sass < Stylesheet
        def initialize(plugin, base, file)
          @plugin = plugin
          @base = base
          @file = file
          @media = media || 'all'
          @root = plugin.assets_path
          @dir = File.join(plugin.slug, base)
          @exists = {}
          file_check
        end

        def tag
          "<link href='#{Filters.expand_url(File.join(dir, file))}' media='#{@media}' rel='stylesheet' type='text/css'>"
        end

        def add
          unless file =~ /^_/
            Plugins.add_css_tag tag
            Plugins.static_files << StaticFileContent.new(compile, destination)
          end
        end

        def ext
          path.extname
        end

        def load_paths
          lp = [theme_load_path]
          lp.unshift user_load_path if Dir.exists? user_load_path
          lp
        end

        def disabled?
          is_disabled('sass', filename) || is_disabled('stylesheets', filename)
        end

        def compile
          PluginAssetPipeline.compile_sass(self)
        end

        def destination
          File.join(base, plugin.slug, file.sub(/@(.+?)\./,'.').sub(/s.ss/, 'css'))
        end

        private

        def user_load_path
          File.join(Octopress.site.source, Plugins.custom_dir, dir, File.dirname(file)).sub /\/\.$/, ''
        end

        def theme_load_path
          File.expand_path(File.join(root, base))
        end

        def user_override_path
          # Allow Sass overrides to use either syntax
          if file =~ /s[ac]ss$/
            [File.join(user_dir, file), File.join(user_dir, alt_syntax_file)]
          else
            File.join user_dir, file
          end
        end

        def alt_syntax_file
          ext = File.extname(file)
          alt_ext = (ext == '.scss' ? '.sass' : '.scss')
          file.sub(ext, alt_ext)
        end

      end
    end
  end
end


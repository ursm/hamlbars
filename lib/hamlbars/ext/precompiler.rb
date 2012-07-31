require 'execjs'

module Hamlbars
  module Ext
    module Precompiler

      def self.included(base)
        base.extend ClassMethods
      end

      # Takes the rendered template and compiles it using the Handlebars
      # compiler via ExecJS.
      def hb_template_js_with_precompiler(template)
        if self.class.precompiler_enabled? 
          precompiledTemplate = runtime.call('precompileEmberHandlebars', template)
          "Em.Handlebars.template(#{precompiledTemplate})"
        else
          hb_template_js_without_precompiler(template)
        end
      end

      private
      def runtime
        Thread.current[:hamlbars_js_runtime] ||= ExecJS.compile(js)
      end

      def js
        [ 'handlebars-1.0.0.beta.6.js', 'headless-ember.js', 'ember-prod.js' ].map do |name|
          File.read(File.expand_path("../../../../vendor/javascripts/#{name}", __FILE__))
        end.join("\n")
      end

      module ClassMethods
        # Enables use of the Handlebars compiler when rendering
        # templates.
        def enable_precompiler!
          @precompiler_enabled = true
          unless public_method_defined? :hb_template_js_without_precompiler
            alias_method :hb_template_js_without_precompiler, :hb_template_js
            alias_method :hb_template_js, :hb_template_js_with_precompiler
          end
        end

        def precompiler_enabled?
          !!@precompiler_enabled
        end

        def disable_precompiler!
          @precompiler_enabled = false
        end
      end

    end
  end
end

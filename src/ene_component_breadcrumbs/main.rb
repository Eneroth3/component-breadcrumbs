module Eneroth
  module ComponentBreadcrumbs
    # Vary superclass depending on whether this SketchUp version has overlays.
    super_class = defined?(Sketchup::Overlay) ? Sketchup::Overlay : Object

    class Breadcrumbs < super_class
      def initialize
        if defined?(Sketchup::Overlay)
          super(PLUGIN_ID, EXTENSION.name, description: EXTENSION.description)
        end
      end

      # Use Both Tool and Overlay API to make the extension work in old SU
      # versions.

      # @api sketchup-observers
      # https://ruby.sketchup.com/Sketchup/Tool.html
      def activate
        Sketchup.active_model.active_view.invalidate
      end

      # @api sketchup-observers
      # https://ruby.sketchup.com/Sketchup/Tool.html
      def resume(view)
        view.invalidate
      end

      # @api sketchup-observers
      # @see https://ruby.sketchup.com/Sketchup/Overlay.html
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def draw(view)
        position = [20, 20]
        options = { size: 12 }
        view.draw_text(position, breadcrumb_text(view), options)
      end

      def breadcrumb_text(view)
        crumbs = [filename(view.model)]
        # active_path returns nil, not empty Array, when at top level -_- .
        crumbs += (view.model.active_path || []).map { |i| crumb_text(i) }

        crumbs.join(" › ")
      end

      def filename(model)
        return "Untitled" if model.path == ""

        File.basename(model.path)
      end

      def crumb_text(instance)
        text = display_name(instance)
        # Don't display count for Groups. They represent unique objects and are
        # silently made unique when edited.
        text += " (#{instance.definition.count_used_instances})" if instance.is_a?(Sketchup::ComponentInstance)

        text
      end

      def display_name(instance)
        # Components are recognized by definition name, the class of identical
        # objects. Groups may have an optional instance name, but their
        # definition name is not user facing in SketchUp. Fall back to entity
        # name for unnamed groups. Groups represent unique objects, making the
        # definition name irrelevant.
        return instance.definition.name if instance.is_a?(Sketchup::ComponentInstance)
        return instance.name unless instance.name == ""

        "Group"
      end
    end

    if defined?(Sketchup::Overlay)
      # If SketchUp has Overlays API, use it.
      class OverlayAttacher < Sketchup::AppObserver
        def expectsStartupModelNotifications
          true
        end

        def register_overlay(model)
          overlay = Breadcrumbs.new
          model.overlays.add(overlay)
        end
        alias_method :onNewModel, :register_overlay
        alias_method :onOpenModel, :register_overlay
      end

      observer = OverlayAttacher.new
      Sketchup.add_observer(observer)

      observer.register_overlay(Sketchup.active_model)
    else
      # For legacy SketchUp, fall back on Tool API and menu item.
      unless @loaded
        @loaded = true

        menu = UI.menu("Plugins")
        menu.add_item(EXTENSION.name) { Sketchup.active_model.select_tool(Breadcrumbs.new) }
      end
    end
  end
end

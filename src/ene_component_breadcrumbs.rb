# frozen_string_literal: true

require "extensions"

# Eneroth Extensions
module Eneroth
  # Eneroth Component Breadcrumbs
  module ComponentBreadcrumbs
    path = __FILE__.dup
    path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

    # Identifier for this extension.
    PLUGIN_ID = File.basename(path, ".*")

    # Root directory of this extension.
    PLUGIN_ROOT = File.join(File.dirname(path), PLUGIN_ID)

    # Extension object for this extension.
    EXTENSION = SketchupExtension.new(
      "Eneroth Component Breadcrumbs",
      File.join(PLUGIN_ROOT, "main")
    )

    EXTENSION.creator     = "Eneroth"
    EXTENSION.description = "Display the name and count of all open components."
    EXTENSION.version     = "1.0.0"
    EXTENSION.copyright   = "2024, #{EXTENSION.creator}"
    Sketchup.register_extension(EXTENSION, true)
  end
end

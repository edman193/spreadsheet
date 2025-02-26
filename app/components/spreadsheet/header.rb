# frozen_string_literal: true

require_relative './row'

module Spreadsheet
  # Header is a special Row component use it for heading in your sheet
  class Header < Row
    attr_reader :columns, :locked

    renders_one :header_actions_menu
    renders_one :header_context_menu

    def initialize(id:, columns: [], locked: {}, **opts)
      super
      @colspans = opts[:colspans] || {}
      @classnames = opts[:classnames] || {}
      @labels = opts[:labels] || {}
      @columns = setup_columns(columns)
      @locked = locked.map(&:to_sym)
    end

    def component_classnames
      grid = @classnames[:grid] || default_grid_classnames
      padding = @classnames[:padding] || default_padding_classnames
      "#{grid} #{padding} relative bg-gray-500 text-center sticky top-0 z-10"
    end

    def default_grid_classnames
      'grid grid-flow-col grid-cols-auto gap-0 auto-cols-fr'
    end

    def default_padding_classnames
      CssClassString::Helper.new('pl-1', 'pr-8' => show_dropdown?)
    end

    def default_cell_grid_classnames(id)
      "col-span-#{colspan_for(id)}"
    end

    def classnames_for(id)
      grid = @classnames[:cell_grid] || default_cell_grid_classnames(id)
      [@classnames[:all], @classnames[id], "#{grid} #{id}"].compact.join(' ')
    end

    def colspan_for(id)
      @colspans[id] || 1
    end

    def label_for(id)
      @labels[id] || id.to_s.titleize
    end

    def show_context_menu?
      header_context_menu.present?
    end

    def show_dropdown?
      selectable_menu || header_actions_menu.present?
    end

    private

    def default_component_controller
      'spreadsheet--header'
    end

    def setup_columns(columns)
      columns.map do |column|
        if column.class.ancestors.include? ViewComponent::Base
          column
        else
          default_column(column)
        end
      end
    end

    def default_column(column)
      Spreadsheet::HeaderColumn.new(**column_hash(column))
    end

    def normalize_hash(column)
      case column
      when Hash
        column
      else
        { id: column.to_sym }
      end
    end

    def column_hash(column)
      col_opts = normalize_hash(column)
      col_opts.merge(
        classnames: col_opts[:classnames] || classnames_for(col_opts[:id]),
        label: col_opts[:label] || label_for(col_opts[:id])
      )
    end

    def default_data
      {
        controller: component_controller,
        action: "contextmenu->#{component_controller}#menu"
      }
    end
  end
end

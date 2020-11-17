class Spreadsheet::Row < ViewComponent::Base
  attr_reader :id
  attr_reader :parent
  attr_reader :opts

  with_content_areas :actions_menu

  def initialize(id:, visible_cells: [], **opts)
    @id = id
    @visible_cells = visible_cells.map(&:to_sym)
    @cells = []
    @opts = opts

    RequestStore.store[:row] = self
  end

  def classnames
    CssClassString::Helper.new(id, @opts[:heading_css], draggable: @opts[:draggable]).to_s
  end

  def display_cell?(id)
    # if no visible cells defined then show all
    @visible_cells.empty? || @visible_cells.include?(id.to_sym)
  end

  def draghandle
    opts[:draghandle]
  end

  def draggable
    opts[:draggable]
  end

  def nesting_level
    opts[:nesting_level] || 0
  end

end
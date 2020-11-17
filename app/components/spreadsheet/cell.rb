class Spreadsheet::Cell < ViewComponent::Base
  attr_reader :id
  attr_reader :value
  attr_reader :colspan
  attr_reader :opts

  def initialize(id:, value: "&nbsp;".html_safe, colspan: 1, **opts)
    @id = id
    @value = value
    @colspan = colspan

    # let row's options serve as defaults for this cell
    @opts =  row.opts.merge(opts)
  end

  def classnames
    CssClassString::Helper.new(id, "col-span-#{colspan}", numeric_class, readonly: readonly, money: opts[:money], error: error).to_s
  end

  def content
    super || value
  end

  def data
    { type: id,
      value: value,
      nesting_level: nesting_level,
      controller: "spreadsheet--cell",
      action: "keyup->spreadsheet--cell#navigate mousedown->spreadsheet--row#highlight focus->spreadsheet--cell#focus",
      error: error }
  end


  def disabled
    opts[:disabled]
  end

  def error
    opts[:error]
  end

  def expander
    opts[:expander]
  end

  def nesting_level
    opts[:nesting_level]
  end

  def numeric_class
    return unless value.to_s =~ /\$[\d\,]+\.[\d\d]*/

    CssClassString::Helper.new("text-right", negative: (numeric_value < 0)).to_s
  end

  def readonly
    opts[:readonly]
  end

  def render?
    row.display_cell?(id)
  end

  private

  def numeric_value
    case value
    when String
      value.gsub(/[^\d\.-]/,"").to_f
    when Numeric
      value
    end
  end

  def row
    RequestStore.store[:row] || {}
  end
end
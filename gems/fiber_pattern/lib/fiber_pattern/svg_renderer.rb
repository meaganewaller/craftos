# frozen_string_literal: true

module FiberPattern
  # Renders a Schematic as an SVG string with piece outlines, dimension lines,
  # measurement labels, and shaping markers.
  class SvgRenderer
    PADDING = 40
    PIECE_SPACING = 60
    DEFAULT_SCALE = 10
    LABEL_OFFSET = 25
    FONT_SIZE = 12
    MARKER_RADIUS = 3

    # @param schematic [FiberPattern::Schematic] schematic to render
    # @param scale [Numeric] pixels per inch (default 10)
    def initialize(schematic, scale: DEFAULT_SCALE)
      @schematic = schematic
      @scale = scale
    end

    # @return [String] complete SVG document
    def render
      pieces = @schematic.pieces.values
      return empty_svg if pieces.empty?

      layouts = compute_layouts(pieces)
      total_width = layouts.last[:x] + layouts.last[:w] + PADDING + LABEL_OFFSET + FONT_SIZE * 3
      total_height = layouts.map { |l| l[:h] }.max + (PADDING + LABEL_OFFSET + FONT_SIZE) * 2

      parts = [svg_header(total_width, total_height)]
      layouts.each do |layout|
        parts << render_piece(layout[:piece], layout[:x], PADDING + LABEL_OFFSET + FONT_SIZE)
      end
      parts << svg_footer

      parts.join("\n")
    end

    private

    def compute_layouts(pieces)
      layouts = []
      x = PADDING

      pieces.each do |piece|
        w = (piece.bottom_width.to(:inches).value * @scale).round
        top_w = (piece.top_width.to(:inches).value * @scale).round
        w = [w, top_w].max
        h = (piece.height.to(:inches).value * @scale).round

        layouts << {piece: piece, x: x, w: w, h: h}
        x += w + PIECE_SPACING
      end

      layouts
    end

    def render_piece(piece, x_offset, y_offset)
      bottom_w = (piece.bottom_width.to(:inches).value * @scale).round
      top_w = (piece.top_width.to(:inches).value * @scale).round
      h = (piece.height.to(:inches).value * @scale).round
      max_w = [bottom_w, top_w].max

      parts = []
      parts << %(<g data-piece="#{escape_xml(piece.name.to_s)}">)
      parts << render_outline(piece, x_offset, y_offset, max_w, bottom_w, top_w, h)
      parts << render_label(piece, x_offset, y_offset, max_w, h)
      parts << render_dimension_lines(piece, x_offset, y_offset, max_w, bottom_w, top_w, h)
      parts << render_shaping_markers(piece, x_offset, y_offset, max_w, bottom_w, top_w, h) if piece.shaping
      parts << "</g>"

      parts.join("\n")
    end

    def render_outline(piece, x, y, max_w, bottom_w, top_w, h)
      if piece.shape == :rectangle
        %(<rect x="#{x}" y="#{y}" width="#{bottom_w}" height="#{h}" ) +
          %(fill="none" stroke="#333" stroke-width="2"/>)
      else
        bottom_offset = (max_w - bottom_w) / 2
        top_offset = (max_w - top_w) / 2

        x1 = x + bottom_offset
        x2 = x + bottom_offset + bottom_w
        x3 = x + top_offset + top_w
        x4 = x + top_offset

        %(<polygon points="#{x1},#{y + h} #{x2},#{y + h} #{x3},#{y} #{x4},#{y}" ) +
          %(fill="none" stroke="#333" stroke-width="2"/>)
      end
    end

    def render_label(piece, x, y, max_w, h)
      cx = x + max_w / 2
      cy = y + h / 2

      %(<text x="#{cx}" y="#{cy}" text-anchor="middle" dominant-baseline="middle" ) +
        %(font-family="sans-serif" font-size="#{FONT_SIZE + 2}" fill="#666">) +
        %(#{escape_xml(piece.name.to_s)}</text>)
    end

    def render_dimension_lines(piece, x, y, max_w, bottom_w, top_w, h)
      parts = []

      # Bottom width dimension (below the piece)
      bottom_offset = (max_w - bottom_w) / 2
      dim_y = y + h + LABEL_OFFSET
      bx1 = x + bottom_offset
      bx2 = x + bottom_offset + bottom_w

      parts << dimension_line(bx1, dim_y, bx2, dim_y,
        format_measurement(piece.bottom_width))

      # Top width dimension (above the piece)
      if piece.shape == :trapezoid
        top_offset = (max_w - top_w) / 2
        dim_y_top = y - LABEL_OFFSET
        tx1 = x + top_offset
        tx2 = x + top_offset + top_w

        parts << dimension_line(tx1, dim_y_top, tx2, dim_y_top,
          format_measurement(piece.top_width))
      end

      # Height dimension (right side)
      dim_x = x + max_w + LABEL_OFFSET
      parts << dimension_line(dim_x, y, dim_x, y + h,
        format_measurement(piece.height))

      parts.join("\n")
    end

    def render_shaping_markers(piece, x, y, max_w, bottom_w, top_w, h)
      return "" unless piece.shaping

      total_rows = piece.rows.value
      parts = []

      piece.shaping.schedule.each do |event|
        row = event[:row]
        ratio = row.to_f / total_rows
        marker_y = y + h - (ratio * h).round

        # Width at this row (linear interpolation)
        width_at_row = bottom_w + (top_w - bottom_w) * ratio
        bottom_offset = (max_w - bottom_w) / 2
        top_offset = (max_w - top_w) / 2
        left_x = x + bottom_offset + (top_offset - bottom_offset) * ratio
        right_x = left_x + width_at_row

        parts << %(<circle cx="#{left_x.round}" cy="#{marker_y}" r="#{MARKER_RADIUS}" fill="#e74c3c"/>)
        parts << %(<circle cx="#{right_x.round}" cy="#{marker_y}" r="#{MARKER_RADIUS}" fill="#e74c3c"/>)
      end

      parts.join("\n")
    end

    def dimension_line(x1, y1, x2, y2, label)
      # Determine if horizontal or vertical
      horizontal = y1 == y2
      mid_x = (x1 + x2) / 2
      mid_y = (y1 + y2) / 2

      tick_size = 5
      parts = []

      # Main line
      parts << %(<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" stroke="#999" stroke-width="1"/>)

      if horizontal
        # End ticks (vertical)
        parts << %(<line x1="#{x1}" y1="#{y1 - tick_size}" x2="#{x1}" y2="#{y1 + tick_size}" stroke="#999" stroke-width="1"/>)
        parts << %(<line x1="#{x2}" y1="#{y2 - tick_size}" x2="#{x2}" y2="#{y2 + tick_size}" stroke="#999" stroke-width="1"/>)
        # Label
        parts << %(<text x="#{mid_x}" y="#{mid_y - 6}" text-anchor="middle" ) +
          %(font-family="sans-serif" font-size="#{FONT_SIZE}" fill="#333">#{label}</text>)
      else
        # End ticks (horizontal)
        parts << %(<line x1="#{x1 - tick_size}" y1="#{y1}" x2="#{x1 + tick_size}" y2="#{y1}" stroke="#999" stroke-width="1"/>)
        parts << %(<line x1="#{x2 - tick_size}" y1="#{y2}" x2="#{x2 + tick_size}" y2="#{y2}" stroke="#999" stroke-width="1"/>)
        # Label (rotated)
        parts << %(<text x="#{mid_x + FONT_SIZE}" y="#{mid_y}" text-anchor="middle" ) +
          %(font-family="sans-serif" font-size="#{FONT_SIZE}" fill="#333">#{label}</text>)
      end

      parts.join("\n")
    end

    def format_measurement(length)
      value = length.to(:inches).value
      "#{value.round(1)}&quot;"
    end

    def escape_xml(str)
      str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
    end

    def svg_header(width, height)
      %(<svg xmlns="http://www.w3.org/2000/svg" width="#{width}" height="#{height}" ) +
        %(viewBox="0 0 #{width} #{height}">)
    end

    def svg_footer
      "</svg>"
    end

    def empty_svg
      svg_header(0, 0) + "\n" + svg_footer
    end
  end
end

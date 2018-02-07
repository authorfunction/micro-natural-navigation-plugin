VERSION = "1.1.0-0.0.2"

-- af=authorfunction
-- versioning test
local lastpos = CurView().Cursor.X

function GetCurrentVisualLine()
    return CurView().Cursor.Y + 1 -- Because this is zero-indexed
end

function GetCurrentLineLength()
    local line_index = CurView().Cursor.Y
    local current_line_contents = CurView().Buf:Line(line_index)
    local line_length = string.len(current_line_contents)
    return line_length
end

-- authorfunction hack: offset is wrong by +3, so subtract 3...
function MoveDown()
    local line_length = GetCurrentLineLength()
    local raw_offset = CurView().Cursor.X + CurView().Width
    if line_length > CurView().Width and raw_offset < line_length then
       	CurView().Cursor.X = CurView().Cursor.X + CurView().Width -3 -- <== hack
   	else
		CurView().Cursor:Down()
    end
end

function NavigateDown()
    local total_lines = CurView().Buf.NumLines
    local current_line = GetCurrentVisualLine()
    if current_line == total_lines then
        CurView().Cursor:End()
    else
        if CurView().Buf.Settings["softwrap"] then
            MoveDown()
        else
            CurView().Cursor:Down()
        end
    end
end

-- authorfunction hack: offset is wrong by -3, so add 3...
function MoveUp()
    local line_length = GetCurrentLineLength()
    local raw_offset = CurView().Cursor.X - CurView().Width

    if line_length > CurView().Width and raw_offset > 0 then
        CurView().Cursor.X = math.max(0, raw_offset) + 3 -- <== hack
        CurView().Cursor:StoreVisualX()
    else
    	CurView().Cursor:Up()
    end
end

function NavigateUp()
    local current_line = GetCurrentVisualLine()

    if current_line == 1 then
        CurView().Cursor:Start()
    else
        if CurView().Buf.Settings["softwrap"] then
            MoveUp()
        else
            CurView().Cursor:Up()
        end
    end
end


-- autorfunction, added: BindKeys for automatic setup
BindKey("Up", "natural.NavigateUp")
BindKey("Down", "natural.NavigateDown")

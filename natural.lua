VERSION = "1.1.0-1"

local savedPos=CurView().Cursor.X
local atEOL=0
local r=3

-- Slow and ugly hack, but cursor movement with wrapped lines is almost 
-- consistent. A bit flaky but imilar although not identicial to Word...

function GetCurrentVisualLine()
    return CurView().Cursor.Y + 1 -- Because this is zero-indexed
end

function GetCurrentLineLength()
    local line_index = CurView().Cursor.Y
    local current_line_contents = CurView().Buf:Line(line_index)
    local line_length = string.len(current_line_contents)
    return line_length
end

function GetPreviousLineLength()
    local line_index = CurView().Cursor.Y - 1
    local current_line_contents = CurView().Buf:Line(line_index)
    local line_length = string.len(current_line_contents)
    return line_length
end

function GetNextLineLength()
    local line_index = CurView().Cursor.Y + 1
    local current_line_contents = CurView().Buf:Line(line_index)
    local line_length = string.len(current_line_contents)
    return line_length
end

function MoveDown()
    local line_length = GetCurrentLineLength()
    local raw_offset = CurView().Cursor.X + CurView().Width
    if line_length > CurView().Width and raw_offset < line_length then
        CurView().Cursor.X = math.min(line_length, raw_offset) - r -- <== hack
    else
        CurView().Cursor:Down()
    end
end

function MoveUp() -- af: rewritten
    local line_length = GetCurrentLineLength()
    local raw_offset = CurView().Cursor.X - CurView().Width
    if line_length > CurView().Width and raw_offset > 0 then
        CurView().Cursor.X = math.max(0, raw_offset) + r -- <== hack
    else
        local next_line_length = GetPreviousLineLength()
        if next_line_length == 0 then
        	CurView().Cursor:Start()
			CurView().Cursor:Left()
        elseif line_length == 0 then
        	CurView().Cursor:Left()
        else
        	local savedPos=CurView().Cursor.X
        	CurView().Cursor:Start()
        	CurView().Cursor:Left()
        end
    end
end


--------- REWRITE:
--------- Works, but more slowly than MoveUp()
function MoveDown() -- af: rewritten

    local line_length = GetCurrentLineLength()
    local raw_offset = CurView().Cursor.X + CurView().Width-r

	local w=CurView().Width-r
	local wrappedLines=math.ceil( (line_length/w) )
	local maxLen=wrappedLines*w

	-->Ugly hack, compensates for rounding error (?) in wrappedLines:
	local pos = CurView().Cursor.X
	local magicNum = w-(maxLen %  pos)
	if magicNum<0 then -- if negative, sub from width to get correct value
		magicNum=w+magicNum
	end --<

	local oldX=pos --CurView().Cursor.X
	local newX=pos+w --CurView().Cursor.X+w
	CurView().Cursor.X=newX

	local diff = CurView().Cursor:GetVisualX()-newX
	local next_line_length = GetNextLineLength()
	--> spaghetti if ... else block deals with edge cases:
	if diff < 0 and atEOL==0 then
		if next_line_length == 0 then
			CurView().Cursor:Down()
			elseif line_length > 0 then 
				atEOL=1
			else
				CurView().Cursor:Down()
				CurView().Cursor.X=magicNum
		end
		elseif atEOL==1 then
			CurView().Cursor:End()
			CurView().Cursor:Right()
			CurView().Cursor.X=magicNum
			atEOL=0
	end --<
end

---------
---------

function NavigateDown()
	-- compensate for ruler if needed
		if CurView().Buf.Settings["ruler"] then
			r=3
		else
			r=0
		end
	
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
    CurView().Cursor:StoreVisualX()
    CurView():Relocate()
end

function NavigateUp()
	-- compensate for ruler
	if CurView().Buf.Settings["ruler"] then
		r=3
	else
		r=0
	end
	
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
    CurView().Cursor:StoreVisualX()
    CurView():Relocate()
end

-- autorfunction, added: BindKeys for automatic setup
BindKey("Up", "natural.NavigateUp")
BindKey("Down", "natural.NavigateDown")

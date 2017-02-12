VERSION = "1.0.0"

function NavigateDown()
    local total_lines = CurView().Buf.NumLines
    local current_line = CurView().Cursor.Y + 1 -- Because this is zero-indexed
    if current_line == total_lines then
        CurView().Cursor:End()
    else
        CurView().Cursor:Down()
    end
end

function NavigateUp()
    local current_line = CurView().Cursor.Y + 1 -- Because this is zero-indexed
    if current_line == 1 then
        CurView().Cursor:Start()
    else
        CurView().Cursor:Up()
    end
end

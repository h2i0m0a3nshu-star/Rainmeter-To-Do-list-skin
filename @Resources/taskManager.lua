function Initialize()
    filePath = SKIN:GetVariable("TaskFile")
    tasks = ReadTasks(filePath)
    SKIN:Bang("!SetVariable TaskCount", #tasks)
    for i, task in ipairs(tasks) do
        SKIN:Bang("!SetVariable Task"..i.."Text", task.text)
        SKIN:Bang("!SetVariable Task"..i.."Done", task.done)
    end
end

function ReadTasks(path)
    local f = io.open(path, "r")
    if not f then return {} end
    local lines = {}
    for line in f:lines() do
        local done, text, date, prio = line:match("(%d)|([^|]+)|([^|]+)|(%d)")
        table.insert(lines, {done=done, text=text, date=date, prio=prio})
    end
    f:close()
    return lines
end

function ToggleTask(index)
    tasks[index].done = (tasks[index].done == "1") and "0" or "1"
    SaveTasks(filePath, tasks)
    SKIN:Bang("!Update")
end

function SaveTasks(path, taskList)
    local f = io.open(path, "w+")
    for _, t in ipairs(taskList) do
        f:write(t.done.."|"..t.text.."|"..t.date.."|"..t.prio.."\n")
    end
    f:close()
end

function AddTask(text, date, prio)
    table.insert(tasks, {done="0", text=text, date=date, prio=prio})
    SaveTasks(filePath, tasks)
    SKIN:Bang("!Refresh")
end

function RemoveCompleted()
    local active = {}
    for _, t in ipairs(tasks) do
        if t.done == "0" then table.insert(active, t) end
    end
    SaveTasks(filePath, active)
    SKIN:Bang("!Refresh")
end
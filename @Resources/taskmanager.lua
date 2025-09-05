divider = '|'

function initialize()
    taskFilePath = SELF:GetOption('TaskListFile')
end

-- Function that analyzes what kind of command has been entered in the terminal
function analyzeCMD(newcommand)
    local cmd;
    local statement;
    if(newcommand == 'add') then addtasks() 
end


-- Read tasks from file and return as table of task objects
function readtasks()
    local file = io.open(taskFilePath, 'r')
    if not file then return {} end

    local tasklist = {}
    for line in file:lines() do
        local done, text, date, prio = line:match("(%d)|([^|]+)|([^|]+)|(%d)")
        if done and text and date and prio then
            table.insert(tasklist, {
                done = tonumber(done),
                text = text,
                date = date,
                prio = tonumber(prio)
            })
        end
    end
    file:close()
    return tasklist
end

-- Save task table back to file
function savetasks(tasklist)
    local file = io.open(taskFilePath, 'w+')
    for _, task in ipairs(tasklist) do
        file:write(string.format("%d%s%s%s%s%s%d\n",
            task.done, divider, task.text, divider, task.date, divider, task.prio))
    end
    file:close()
end

-- Add a new task to the list
function addtasks(newText, dueDate, priority)
    local tasks = readtasks()
    table.insert(tasks, {
        done = 0,
        text = newText,
        date = dueDate,
        prio = tonumber(priority)
    })
    savetasks(tasks)
    SKIN:Bang("!Refresh")
end

-- Format task for display (optional: add color or symbols)
function formatTask(task)
    local checkbox = task.done == 1 and "☑" or "☐"
    return string.format("%s %s (Due: %s) [Prio: %d]", checkbox, task.text, task.date, task.prio)
end

-- Toggle completion status of a task
function changeStatus(index)
    local tasks = readtasks()
    if tasks[index] then
        tasks[index].done = tasks[index].done == 1 and 0 or 1
        savetasks(tasks)
        SKIN:Bang("!Refresh")
    end
end

-- Change priority of a task
function changePrio(index, newPrio)
    local tasks = readtasks()
    if tasks[index] then
        tasks[index].prio = tonumber(newPrio)
        savetasks(tasks)
        SKIN:Bang("!Refresh")
    end
end

-- Remove all completed tasks
function removeCompleted()
    local tasks = readtasks()
    local active = {}
    for _, task in ipairs(tasks) do
        if task.done == 0 then
            table.insert(active, task)
        end
    end
    savetasks(active)
    SKIN:Bang("!Refresh")
end

-- Sort tasks by due date or priority
function sortTasks(by)
    local tasks = readtasks()
    table.sort(tasks, function(a, b)
        if by == "date" then
            return a.date < b.date
        elseif by == "priority" then
            return a.prio < b.prio
        else
            return false
        end
    end)
    savetasks(tasks)
    SKIN:Bang("!Refresh")
end
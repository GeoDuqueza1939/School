// create tasks plugin object
var taskPlugin = {
    name: 'Tasks',
    id: 'tasksPlugin',
    isEnabled: true,
    hasMenuEntry: true,
    isSelected: false,
    // create wrappers
    wrapperMenuItem: undefined,
    wrapperPlugManItem: undefined,

    // create assets
    //  tags
    clientData: '<div class="pluginClient" id="tasksClient">' +
        '<h1 class="pluginClientHeading">Tasks</h1>' +
        '<div id="taskClientTaskList">' +
        '<p>It feels gloomy here. Why not add a task or two to make life a whole lot better?</p>' +
        '</div>' +
        '<img src="images/add-circle.png" alt="Add Task" id="add-task-button" onclick="openTaskForm()" />' +
        '</div>',
    clientId: 'tasksClient',

    addTaskFormTags: '<div id="addTaskForm">' +
        '<form>' +
        '<p>Please enter the task details:</p>' +
        '<label for="">Task Name:</label><br /><input type="text" value="" id="taskText" name="taskText" /><br /><br />' +
        '<label for="">Description:</label><br /><input type="text" value="" id="taskDesc" name="taskDesc" /><br /><br />' +
        '<label for="">Type:</label><br /><input type="text" value="" id="taskType" name="taskType" /><br /><br />' +
        '<label for="">Schedule/Deadline:</label><br /><input type="text" value="" id="taskSchedule" name="taskType" /><br /><br />' +
        '<label for="">Alarm Time:</label><br /><input type="text" value="" id="taskAlarm" name="taskType" /><br /><br />' +
        '<p class="align-right"><button id="finishAddTask" name="finishAddTask" onclick="addTask()">Add Task</button>&nbsp;<button id="cancelAddTask" name="cancelAddTask" onclick="closeTaskForm()">Cancel</button></p>' +
        '</form>' +
        '</div>'
};

// add task plugin object to plugin collections
plugins.push(taskPlugin);

var taskCSS = document.createElement('LINK');
taskCSS.setAttribute('rel', 'stylesheet');
taskCSS.setAttribute('type', 'text/css');
taskCSS.setAttribute('href', 'css/plugins/tasks.css');

document.getElementsByTagName('HEAD')[0].appendChild(taskCSS);

// task object
function Task(name, desc, type, schedule, alarmTime)
{
    this.name = name;
    this.desc = desc;
    this.schedule = schedule;
    this.alarmTime = alarmTime;
    this.type = type;
}

// task collection (initially empty)
var tasks = [];

function openTaskForm()
{
    document.getElementById('tasksClient').innerHTML += taskPlugin.addTaskFormTags;
    document.getElementById('add-task-button').classList.add('hidden');
}

function addTask()
{
    var taskText = document.getElementById('taskText').value;
    var taskDesc = document.getElementById('taskDesc').value;
    var taskType = document.getElementById('taskType').value;
    var taskSchedule = document.getElementById('taskSchedule').value;
    var taskAlarm = document.getElementById('taskAlarm').value;

    tasks.push(new Task(taskText, taskDesc, taskType, taskSchedule, taskAlarm))

    refreshTaskList();
    closeTaskForm()
}

function closeTaskForm()
{
    document.getElementById('addTaskForm').parentNode.removeChild(document.getElementById('addTaskForm'));
    document.getElementById('add-task-button').classList.remove('hidden');
}

function refreshTaskList() {
    var taskList = document.getElementById('taskClientTaskList');   

    if (tasks.length > 0)
    {
        taskList.innerHTML = '';

        for (x in tasks)
        {
            var task = tasks[x];
            var item = document.createElement('P');
            item.classList.add('task-item');

            var taskCheck = document.createElement('INPUT');
            taskCheck.setAttribute('type', 'checkbox');
            taskCheck.id = 'task' + x;
            taskCheck.setAttribute('name', taskCheck.id);
            taskCheck.classList.add('task-checkbox');

            var taskCheckSpan = document.createElement('SPAN');
            taskCheckSpan.classList.add('task-checkbox-span');
            taskCheckSpan.appendChild(taskCheck);

            var taskText = document.createElement('SPAN');
            taskText.classList.add('task-item-text');

            var taskName = document.createElement('SPAN');
            taskName.classList.add('task-item-name');
            taskName.appendChild(document.createTextNode(task.name));

            var taskSchedule = document.createElement('SPAN');
            taskSchedule.classList.add('task-item-schedule');
            taskSchedule.appendChild(document.createTextNode(task.schedule));
            
            var taskAlarm = document.createElement('SPAN');
            taskAlarm.classList.add('task-item-alarm');
            taskAlarm.appendChild(document.createTextNode(task.alarmTime));
            
            taskText.appendChild(taskName);
            taskText.appendChild(spaceNode());
            taskText.appendChild(document.createTextNode(task.desc));
            taskText.appendChild(spaceNode());
            taskText.appendChild(taskSchedule);
            taskText.appendChild(spaceNode());
            taskText.appendChild(taskAlarm);

            item.appendChild(taskCheckSpan);
            item.appendChild(taskText);

            taskList.appendChild(item);
        }
    }
    else
    {
        tasklist.innerHTML = '<p>It feels gloomy here. Why not add a task or two to make life a whole lot better?</p>';
    }
}
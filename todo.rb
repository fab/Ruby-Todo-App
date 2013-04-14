require 'csv'

class ListModel
  attr_accessor :list

  def initialize(filename)
    @list = []
    load_list(filename)
  end

  def load_list(filename)
    @id = 1
    CSV.foreach(filename, :quote_char => "\x00") do |row|
      task, completed = row
      list << Task.new(@id, task, completed ? completed : ' ')
      @id += 1
    end
  end

  def add!(task)
    list << Task.new(@id, task)
  end

  def delete!(id)
    list.delete_if { |task_obj| task_obj.id == id }
  end

  def complete!(id)
    list[id - 1].completed = 'X'
  end

  def uncomplete!(id)
    list[id - 1].completed = ' '
  end

  def write_file
    CSV.open('todo.csv', "wb", :quote_char => "\x00") do |csv|
      list.each { |task_obj| csv << [task_obj.task, task_obj.completed] }
    end
  end
end

class ListController
  attr_reader :model, :view, :command, :option, :task_id

  def initialize(filename, command, option)
    system "clear"
    @model = ListModel.new(filename)
    @view = ListView.new
    @command = command
    @option = option
    @task_id = option[0].to_i
    parse_option
  end

  private

  def parse_option
    case command
    when 'list'
      view.display_tasks(model.list)
    when 'add'
      model.add!(option.join(' '))
      view.display_added_task(option.join(' '))
    when 'delete'
      model.delete!(task_id)
      view.display_deleted_task(task_id)
    when 'complete'
      model.complete!(task_id)
      view.display_completed_task(task_id)
    when 'uncomplete'
      model.uncomplete!(task_id)
      view.display_uncompleted_task(task_id)
    end
    model.write_file
  end
end

class ListView
  def display_tasks(todo_list)
    puts todo_list
  end

  def display_added_task(option)
    puts "Added #{option} to your TODO list."
  end

  def display_deleted_task(task_id)
    puts "Deleted task #{task_id} from your TODO list."
  end

  def display_completed_task(task_id)
    puts "Completed task #{task_id} on your TODO list."
  end

  def display_uncompleted_task(task_id)
    puts "Uncompleted task #{task_id} on your TODO list."
  end
end


class Task
  attr_accessor :task, :id, :completed

  def initialize(id, task, completed = ' ')
    @id = id
    @task = task
    @completed = completed
  end

  def display_for_list
    "#{self.id}.".ljust(3) + "[#{self.completed}] #{self.task}\n"
  end

  def to_s
    self.display_for_list
  end
end

def main(filename, command, option)
  ListController.new(filename, command, option)
end

main('todo.csv', ARGV[0], ARGV[1..-1])


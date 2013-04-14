require 'csv'

class List
  attr_accessor :list

  def initialize
    @list = []
  end

  def load_list(filename)
    @id = 1
    CSV.foreach(filename, :quote_char => "\x00") do |row|
      task, completed = row
      list << Task.new(@id, task, completed ? completed : ' ')
      @id += 1
    end
  end

  def add(task)
    list << Task.new(@id, task)
    write_file
  end

  def delete(id)
    list.delete_if { |task_obj| task_obj.id == id }
    write_file
  end

  def complete_task(id)
    list[id - 1].completed = 'X'
    write_file
  end

  def uncomplete_task(id)
    list[id - 1].completed = ' '
    write_file
  end

  def write_file
    CSV.open('todo.csv', "wb", :quote_char => "\x00") do |csv|
      list.each { |task_obj| csv << [task_obj.task, task_obj.completed] }
    end
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

if ARGV.any?
  system "clear"
  todo_list = List.new
  todo_list.load_list('todo.csv')
  command = ARGV[0]
  option = ARGV[1..-1]
  task_id = option[0].to_i
  
  if command == 'list'
    puts todo_list.list
  elsif command == 'add'
    todo_list.add(option.join(' '))
    puts "Added #{option.join(' ')} to your TODO list."
  elsif command == 'delete'
    todo_list.delete(task_id)
    puts "Deleted task #{task_id} from your TODO list."
  elsif command == 'complete'
    todo_list.complete_task(task_id)
    puts "Completed task #{task_id} on your TODO list."
  elsif command == 'uncomplete'
    todo_list.uncomplete_task(task_id)
    puts "Uncompleted task #{task_id} on your TODO list."  
  end
  abort # if a ARGV is supplied the code shouldn't do anything else
end

# todo_list = List.new
# todo_list.load_list('todo.csv')
# puts todo_list.list

# todo_list.complete_task(5)
# puts todo_list.list

# todo_list.add("Example task")
# puts todo_list.list

# todo_list.delete(6)
# puts todo_list.list

# todo_list.uncomplete_task(5)
# puts todo_list.list

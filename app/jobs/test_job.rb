class TestJob < ApplicationJob
  queue_as :default

  def perform
    puts "TestJob executado com sucesso!"
  end
end
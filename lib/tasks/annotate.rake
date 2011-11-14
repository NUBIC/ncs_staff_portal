namespace :annotate do
  desc 'Update the model schema annotations'
  task :models do
    sh 'bundle exec annotate --position before'
  end
end

task('db:migrate').enhance do
  task('annotate:models').invoke
end
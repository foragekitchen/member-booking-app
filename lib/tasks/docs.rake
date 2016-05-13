namespace :docs do
  desc 'Copies the (unversioned, ever-changing) documentation-working.html to documentation.html, for public(ish) consumption.'
  task :update do
    cp 'public/documentation-working.html', 'public/documentation.html'
  end
end

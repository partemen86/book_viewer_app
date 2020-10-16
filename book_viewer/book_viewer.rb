require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do 
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title ="The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  redirect "/" unless (1..@contents.size).include? number
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @text = File.read("data/chp#{number}.txt")
  

  erb :chapter
end

get "/search" do
  @results = chapters_matching(params[:query])

  erb :search
end

# redirect
not_found do
  redirect "/"
end

helpers do
  def highlight(text, target)
    text.gsub(target,"<strong>#{target}</strong>")
  end

  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}</p>" 
    end.join
  end
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield(name, number, contents)
  end
end

def chapters_matching(query)
  results = []
  return results unless query && !query.empty?
  each_chapter do |name, number, contents|
    paragraphs = {}
    if contents.include?(query)
      contents.split("\n\n").each_with_index do |paragraph, index|
        paragraphs[index] = paragraph if paragraph.include?(query)
      end
      results << {name: name, number: number, paragraphs: paragraphs}
    end
  end
  results
end



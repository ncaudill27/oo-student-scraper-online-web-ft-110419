require 'nokogiri'
require 'open-uri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    html = open(index_url)
    doc = Nokogiri::HTML(html)
    
    students_array = []

    doc.css("div.roster-cards-container .student-card").each_with_index do |student, index|
      students_array << Hash[
        :name => student.css(".student-name").text,
        :location => student.css(".student-location").text,
        :profile_url => student.css("a").attribute("href").text
      ]
    end
    students_array
  end

  def self.scrape_profile_page(profile_url)
    student_page = Nokogiri::HTML(open(profile_url))
    student_attributes = {}

    links_container = student_page.css(".social-icon-container a")
    try_links = links_container.collect {|link| link.attribute('href').value }
    try_links.each do |link|
      
      if link.include?('linkedin')
        student_attributes[:linkedin] = link
      elsif link.include?('twitter')
        student_attributes[:twitter] = link
      elsif link.include?('github')
        student_attributes[:github] = link
      else
        student_attributes[:blog] = link
      end
    end
    student_attributes[:profile_quote] = student_page.css("div.vitals-text-container div").text
    student_attributes[:bio] = student_page.css("div div.description-holder p").text

    student_attributes
  end
end
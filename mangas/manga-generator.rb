require 'erb'

# Function to get user input
def prompt(message)
  print "#{message}: "
  gets.chomp
end

# Template for the Markdown file
template = <<~TEMPLATE
---
title: <%= urdu_title %>
author: Adeel Tariq
output: html_document
image: /mangas/<%= path %>/0-cover.png
description: Gulzar Maa'rifat is an Urdu scanlations group working to translation and type set various famous manhwas and mangas
apple-touch-icon: /apple-touch-icon.png
icon: /favicon.ico
manifest: /site.webmanifest
mask-icon: /safari-pinned-tab.svg
msapplication-TileColor: #da532c
theme-color: #ffffff
---

<br>
<h1 style="text-align: center;">
<%= urdu_title %>
</h1>

<br>

<files>

<h3 style="text-align: center;">
  <a href="../../">Home</a>
</h3>
TEMPLATE

# Function to compress PNG using pngquant
def compress_png(file)
  compressed_file = file.sub(/\.png$/, '-fs8.png') # pngquant adds -fs8 by default
  system("pngquant --quality=65-80 --force --ext .png #{file}")
  file
end

# Ask for user inputs
urdu_title = prompt("Enter the Urdu title")
path = prompt("Enter the path to the folder containing files")

print "Processing"
# Generate file lines
file_lines = Dir["#{path}/*"].sort.map do |file|
  next unless File.extname(file).downcase == '.png' # Only process PNG files
  print "."
  compressed_file = compress_png(file) # Compress the file
  filename = File.basename(compressed_file)
  "<img src=\"#{filename}\" alt=\"#{filename}\" style=\"display: block;margin-left: auto;margin-right: auto;width:100%;\"/>"
end.join("\n")

# Combine the template with the data
renderer = ERB.new(template)
output = renderer.result(binding).sub('<files>', file_lines)
puts ""
# Write to index.md
output_file = File.join(path, "index.md")
File.write(output_file, output)
puts "Markdown file generated at #{output_file}"


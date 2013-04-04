# coding: utf-8

require 'find'
require 'load_func_maker'



####################################################################

# settings

# set your project name for apply include-guard prefix.
#  e.g. #ifdef __projectName__ClassName__
project_name = "yourProjectName"

# set path of CCB files.
ccb_dir = "../yourProject/CCB/"

# set path of output files
path_to_h = "../yourProject/Classes/LoadFunc.h"
path_to_cpp = "../yourProject/Classes/LoadFunc.cpp"



####################################################################

load_func_maker = LoadFuncMaker.new(project_name)
load_func_maker.base_directory = base_dir

#file open
h = open(path_to_h, "w")
p = open(path_to_cpp, "w")


# pick up files
Dir::glob(ccb_dir + "**/*.ccb").each{ |f_path|
	print f_path, "\n"

	if File.directory?(f_path) || f_path.include?(".ccbproj") || f_path.include?(".ccbresourcelog")
    # none
  elsif f_path.include?(".ccb")
    # create .h/.cpp file
    load_func_maker.add_ccb_file(f_path)
	end
}

# output .h/.cpp file
h.write load_func_maker.output_h_file()
p.write load_func_maker.output_cpp_file()


#file close
h.close()
p.close()


p "done!"

exit






# The MIT License (MIT)
# Copyright (c) 2013 @hako584(kohashi)
#
#    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
#    documentation files (the "Software"), to deal in the Software without restriction, including without limitation
#    the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
#    and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice
#    shall be included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
#    OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
#    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#








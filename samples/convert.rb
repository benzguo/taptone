# split audio into 2 second samples
wav_file = "C2C6.wav"
notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
seconds = 98
(0..seconds/2).step {|i|
	note_name = "#{notes[(i%12)]}#{((i/12) + 2).floor}"
	command = "sox #{wav_file} #{"wav/"+note_name}.wav trim #{2*i} 2"
	print command+"\n"
	system command
}

# convert to caf files
Dir.entries("wav").
select {|f| File.extname(f) == ".wav" }.
map {|f| File.basename(f, ".wav")}.
each {|f| system("afconvert wav/#{f}.wav caf/#{f}.caf -d ima4 -f caff -v")}

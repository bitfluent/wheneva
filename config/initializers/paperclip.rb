# Paperclip by default swallows STDERR when calling ImageMagick, making it
# hard to debug problems with its binaries
Paperclip.options[:swallow_stderr] = false

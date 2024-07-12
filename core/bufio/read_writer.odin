package bufio

import "core:io"

// Read_Writer stores pointers to a Reader and a Writer
Read_Writer :: struct {
	r: ^Reader,
	w: ^Writer,
}


read_writer_init :: proc(rw: ^Read_Writer, r: ^Reader, w: ^Writer) {
	rw.r, rw.w = r, w
}

read_writer_to_stream :: proc(rw: ^Read_Writer) -> (s: io.Stream) {
	s.procedure = _read_writer_procedure
	s.data = rw
	return
}

@(private)
_read_writer_procedure := proc(stream_data: rawptr, mode: io.Stream_Mode, p: []byte, offset: i64, whence: io.Seek_From, loc := #caller_location) -> (n: i64, err: io.Error) {
	rw := (^Read_Writer)(stream_data)
	n_int: int
	#partial switch mode {
	case .Flush:
		err = writer_flush(rw.w, loc=loc)
		return
	case .Read:
		n_int, err = reader_read(rw.r, p, loc=loc)
		n = i64(n_int)
		return
	case .Write:
		n_int, err = writer_write(rw.w, p, loc=loc)
		n = i64(n_int)
		return
	case .Query:
		return io.query_utility({.Flush, .Read, .Write, .Query})
	}
	return 0, .Empty
}

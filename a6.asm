// Written by Zachariah Albers


define(a_r, d0)
define(x_r, d17)
define(dy_r, d18)
define(dydx_r, d19)
define(input_value, d8)
define(result_r, d9)
define(y_r, d22)

define(fd_r, w19)
define(nread_r, x20)
define(buf_base_r, x21)



// Assembler equates
buf_size = 8
alloc = -(16 + buf_size) & -16
dealloc = -alloc
buf_s = 16
AT_FDCWD = -100

.data
minimum_error: .double 0r1e-10 			// A double precision constant

.text
//Format strings
fmt1: 				.string "There is an error opening the file"
fmt2: 				.string " %lf\t   %0.10f\n"
fmt3: 				.string "\n Value               Result\n"
file_path_name: 	.string "input.bin"


		.balign 4





cube_root:
		stp 	x29, x30, [sp, -16]!		// Saves FP and LR registers
		mov 	x29, sp						// Update FP to current SP

		fmov 	d16, 3.0				// d16 = 3.0
		fdiv 	x_r, a_r, d16			// x = a / 3.0


loop:
		fmul 	y_r, x_r, x_r			// y = x * x
		fmul	y_r, y_r, x_r			// y = x * x * x

		fsub 	dy_r, y_r, a_r			// dy = y - a

		fmul 	dydx_r, x_r, x_r		// dydx = x * x
		fmul 	dydx_r, dydx_r, d16			// dydx = 3*x*x

		fdiv 	d20, dy_r, dydx_r			// d20 = dy / dydx
		fsub 	x_r, x_r, d20			// x = x - dy/dydx


		fabs 	d2, dy_r 				// d2 = abs(dy)
		adrp 	x0, minimum_error				// Puts the 'page' address into x0
		add 	x0, x0, :lo12: minimum_error	// Put the lower order 12 bits of minimum_error into x0
		ldr 	d3, [x0]						// loads x0 into d3
		fmul 	d3, d3, a_r					// d3 = d3 * a

		fcmp 	d2, d3						// Compares d2 and d3
		b.gt 	loop						// Branches to loop if d2 is greater than d3 ()

		fmov 	d0, x_r				// Moves x into d0

		ldp 	x29, x30, [sp], 16			// Restore states
		ret									// Returns to calling function


		.global main					// Executes main
main:
		stp 	x29, x30, [sp, alloc]!		// Saves FP and LR registers and allocates space for local variables
		mov 	x29, sp						// Updates FP to current SP



		adrp 	x0, fmt3					// Puts the 'page' address into x0
		add 	x0, x0, :lo12:fmt3			// Put the lower order 12 bits of fmt1 into x0
		bl 		printf							// Branch and link to printf

		// Open existing binary file

		mov 	w0, AT_FDCWD		// Arg 1: AT_FDCWD
		adrp 	x1, file_path_name			// Arg 2: Pathname to file
		add 	x1, x1, :lo12:file_path_name	// Puts x1 into lower order 12 bits
		mov 	w2, 0						// Arg 3: read only
		mov 	w3, 0						// Arg 4: not used
		mov 	x8, 56						// openat I/O request
		svc 	0							// Call system
		mov 	fd_r, w0			// Record the file descriptor

		// Error checking
		cmp 	fd_r, 0				// Compares fd_r and 0
		b.ge	open_file				// Branches to open_file if ther are no errors

		adrp 	x0, fmt1					// Puts the 'page' address into x0
		add 	x0, x0, :lo12:fmt1			// Put the lower order 12 bits of fmt1 into x0
		adrp 	x1, file_path_name				// Puts the 'page' address into x1
		add 	x1, x1, :lo12:file_path_name	// Put the lower order 12 bits of file_path_name into x1
		bl 		printf							// Branch and link to printf
		mov 	w0, -1						// Move -1 into w0
		b 		exit						// Branch to exit

open_file:
		add 	buf_base_r, x29, buf_s		// buf_base_r = x29 + buf_s

top:
		mov 	w0, fd_r					// Arg 1: fd
		mov 	x1, buf_base_r				// Arg 2: ptr to buf
		mov 	w2, buf_size				// Arg 3: n
		mov 	x8, 63						// Reads the I/O request
		svc 	0							// Calls system
		mov 	nread_r, x0					// x0 moved to nread_r

		// Error checking
		cmp 	nread_r, buf_size			// Compares nread_r and buf_size
		b.ne 	end							// Branches to end if not equal

		ldr 	input_value, [buf_base_r]	// Loads buf_base_r into input_value
		fmov 	d0, input_value				// Moves input_value into d0
		bl 		cube_root					// Branch and links to cube_root
		fmov	result_r, d0				// Moves d0 into result_r

		// Print out the long int
		adrp 	x0, fmt2					// Puts the 'page' address into x0
		add 	x0, x0, :lo12:fmt2			// Put the lower order 12 bits of fmt1 into x0
		fmov 	d0, input_value				// Moves input_value into d0
		fmov	d1, result_r				// moves d1 into result_r
		bl 		printf						// Branch and links to printf
		b 		top							// Branches to top

end:
		mov 	w0, fd_r				// moves fd_r to w0
		mov 	x8, 57					// Closes I/O request
		svc 	0						// Calls system

exit:	ldp 	x29, x30, [sp], dealloc			// Restore states
		ret										// Returns to calling function

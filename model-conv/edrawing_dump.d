#!/usr/sbin/dtrace -s

#pragma D option switchrate=1000hz
#pragma D option bufsize=128m

pid$target:libGL.dylib:glGenBuffersARB:entry {
	self->n = arg0;
	self->ids = arg1;
}

pid$target:libGL.dylib:glGenBuffersARB:return {
	printf("%i", *(uint32_t *) copyin(self->ids, 4));
}

pid$target:libGL.dylib:glBindBufferARB:entry /arg1 > 0/ {
	printf("%i %i", arg1, arg0);
}

pid$target:libGL.dylib:glBufferDataARB:entry /arg1 > 0 && arg1 <= 1024/ {
	printf("%i %i %i", arg1, arg0, arg3);
	tracemem(copyin(arg2, arg1), 1024, arg1);
}
pid$target:libGL.dylib:glBufferDataARB:entry /arg1 > 1024 && arg1 <= 16384/ {
	printf("%i %i %i", arg1, arg0, arg3);
	tracemem(copyin(arg2, arg1), 16384, arg1);
}
pid$target:libGL.dylib:glBufferDataARB:entry /arg1 > 16384 && arg1 <= 32768/ {
	printf("%i %i %i", arg1, arg0, arg3);
	tracemem(copyin(arg2, arg1), 32768, arg1);
}
pid$target:libGL.dylib:glBufferDataARB:entry /arg1 > 32768 && arg1 <= 49152/ {
	printf("%i %i %i", arg1, arg0, arg3);
	tracemem(copyin(arg2, arg1), 49152, arg1);
}
pid$target:libGL.dylib:glBufferDataARB:entry /arg1 > 49152 && arg1 <= 131072/ {
	printf("%i %i %i", arg1, arg0, arg3);
	tracemem(copyin(arg2, arg1), 131072, arg1);
}
pid$target:libGL.dylib:glBufferDataARB:entry /arg1 > 131072 && arg1 <= 1048576/ {
	printf("%i %i %i", arg1, arg0, arg3);
	tracemem(copyin(arg2, arg1), 1048576, arg1);
}
pid$target:libGL.dylib:glBufferDataARB:entry /arg1 > 1048576/ {
	printf("MELTDOWN");
	exit(0);
}

pid$target:GLEngine:glDrawElements_Exec:entry {
	printf("%i %i %i %i", arg1, arg2, arg3, arg4);
}

pid$target:EModelViewFW:*FinishedLoadingFile*:entry {
	exit(0);
}

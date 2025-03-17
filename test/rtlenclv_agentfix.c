//before
__try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

    ProbeForWriteSmallStructure(StackFrame,
                                sizeof(PENCLAVE_DISPATCH_FRAME),
                                PROBE_ALIGNMENT(PENCLAVE_DISPATCH_FRAME));

#endif

    StackFrame->ParameterAddress = (PULONG_PTR)TrapFrame->R9;
    StackFrame->OriginalReturn = (PVOID)TrapFrame->Rip;
    StackFrame->FramePointer = (PVOID)TrapFrame->Rbp;
    TrapFrame->Rsp = (ULONG_PTR)StackFrame;

    //
    // Push the trap frame's RIP onto the user-mode shadow stack. This
    // is needed because user-mode will explicitly return to that RIP,
    // instead of the kernel restoring it for user-mode during trap exit.
    //

    RtlpPushUserModeShadowStack(ThreadUserShadowStacksEnabled,
                                TrapFrame->Rip);

} __except (EXCEPTION_EXECUTE_HANDLER) {
    return GetExceptionCode();
}
//after
__try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

    ProbeForWriteSmallStructure(StackFrame,
                                sizeof(PENCLAVE_DISPATCH_FRAME),
                                PROBE_ALIGNMENT(PENCLAVE_DISPATCH_FRAME));

#endif

    WritePointerToUser(&StackFrame->ParameterAddress, (PULONG_PTR)TrapFrame->R9);
    WritePointerToUser(&StackFrame->OriginalReturn, (PVOID)TrapFrame->Rip);
    WritePointerToUser(&StackFrame->FramePointer, (PVOID)TrapFrame->Rbp);
    TrapFrame->Rsp = (ULONG_PTR)StackFrame;

    //
    // Push the trap frame's RIP onto the user-mode shadow stack. This
    // is needed because user-mode will explicitly return to that RIP,
    // instead of the kernel restoring it for user-mode during trap exit.
    //

    RtlpPushUserModeShadowStack(ThreadUserShadowStacksEnabled,
                                TrapFrame->Rip);

} __except (EXCEPTION_EXECUTE_HANDLER) {
    return GetExceptionCode();
}

//before
__try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

    ProbeForWritePointer(StackPointer);

#endif

    Address = ReadPointerNoFence(StackPointer);

    if ((TrapFrame->SegCs == (KGDT64_R3_CODE | RPL_MASK)) &&
        ((Address == CallReturnAddress) || (Address == DispatchReturnAddress))) {

        TrapFrame->Rsp = (ULONG_PTR)(StackPointer + 1);
        TrapFrame->Rip = (ULONG_PTR)Address;
        NT_ASSERT(TrapFrame->Rip == SANITIZE_VA(TrapFrame->Rip,
                                                TrapFrame->SegCs,
                                                UserMode));

        //
        // Pop one return address off the user-mode shadow stack to mirror
        // the adjustment to the data stack.
        //

        RtlpPopUserModeShadowStack(ThreadUserShadowStacksEnabled, 1);

    } else {
        return STATUS_INVALID_PARAMETER;
    }

} __except (EXCEPTION_EXECUTE_HANDLER) {
    return GetExceptionCode();
}
//after
__try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

    ProbeForWritePointer(StackPointer);

#endif

    Address = ReadPointerFromUser(StackPointer);

    if ((TrapFrame->SegCs == (KGDT64_R3_CODE | RPL_MASK)) &&
        ((Address == CallReturnAddress) || (Address == DispatchReturnAddress))) {

        TrapFrame->Rsp = (ULONG_PTR)(StackPointer + 1);
        TrapFrame->Rip = (ULONG_PTR)Address;
        NT_ASSERT(TrapFrame->Rip == SANITIZE_VA(TrapFrame->Rip,
                                                TrapFrame->SegCs,
                                                UserMode));

        //
        // Pop one return address off the user-mode shadow stack to mirror
        // the adjustment to the data stack.
        //

        RtlpPopUserModeShadowStack(ThreadUserShadowStacksEnabled, 1);

    } else {
        return STATUS_INVALID_PARAMETER;
    }

} __except (EXCEPTION_EXECUTE_HANDLER) {
    return GetExceptionCode();
}
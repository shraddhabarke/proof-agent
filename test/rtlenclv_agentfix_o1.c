/*++

Copyright (c)  Microsoft Corporation

Module Name:

    rtlenclv.c

Abstract:

    This module implements routines supporting secure enclaves.

Author:

    Jon Lange (jlange) 22-Sep-2016

Revision History:

--*/

#include "ntrtlp.h"
#define FEATURE_STAGING_LEGACY_MODE
#include "FeatureStaging-Updated-MSRC-GlobalSettings.h"

#if defined(NT_IUM) || defined(IUM_SECUREKERNEL) || defined(VSM_ENCLAVE_RUNTIME) || defined(TRUSTEDAPP_RUNTIME)

NTSTATUS
RtlCreateEnclaveReturnFrame (
    _In_ PVOID ThreadTrapFrame,
    _In_ PVOID DispatchFunction,
    _In_ PVOID DispatchReturn,
    _In_ ULONG_PTR CallingEnclaveNumber,
    _In_ PVOID EnclaveFunction,
    _In_ ULONG FlagsOrStatus,
    _In_ ULONG_PTR ReturnAddress,
    _In_ ULONG_PTR FramePointer,
    _In_ ULONG_PTR Parameter,
    _In_ BOOLEAN ThreadUserShadowStacksEnabled
    )
{
    PENCLAVE_DISPATCH_FRAME StackFrame;
    PKTRAP_FRAME TrapFrame;

#if !defined(_AMD64_)

    UNREFERENCED_PARAMETER(ThreadUserShadowStacksEnabled);

    NT_ASSERT(ThreadUserShadowStacksEnabled == FALSE);

#endif

    TrapFrame = ThreadTrapFrame;

    //
    // Determine whether the current frame corresponds to an enclave return
    // frame.  If so, only parameter injection is required; otherwise,
    // construction of a new stack frame is required.
    //

#if defined(_AMD64_)

    //
    // User-mode trap frames only.
    //

    NT_ASSERT((TrapFrame->SegCs & RPL_MASK) != 0);

    if ((TrapFrame->SegCs != (KGDT64_R3_CODE | RPL_MASK)) ||
        ((PVOID)TrapFrame->Rip != DispatchReturn)) {

        StackFrame = (PENCLAVE_DISPATCH_FRAME)TrapFrame->Rsp - 1;

        __try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

            //
            // Ensures the pointer is a user-mode pointer
            // and checks alignment just as ProbeForWriteSmallStructure
            //

            ExProbeAlignment(StackFrame, sizeof(PENCLAVE_DISPATCH_FRAME), PROBE_ALIGNMENT(PENCLAVE_DISPATCH_FRAME));

#endif

            WritePointerToUser(&StackFrame->ParameterAddress, (PVOID)(ULONG_PTR)TrapFrame->R9);
            WritePointerToUser(&StackFrame->OriginalReturn, (PVOID)(ULONG_PTR)TrapFrame->Rip);
            WritePointerToUser(&StackFrame->FramePointer, (PVOID)(ULONG_PTR)TrapFrame->Rbp);
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
    }

#elif defined(_ARM64_)

    //
    // User-mode service call trap frames only.
    //

    NT_ASSERT((TrapFrame->ExceptionActive == KEXCEPTION_ACTIVE_SERVICE_FRAME) &&
              ((TrapFrame->Spsr & CPSREL_MASK) == CPSREL_0));

    if (((PVOID)TrapFrame->Pc != DispatchReturn)) {

        StackFrame = (PENCLAVE_DISPATCH_FRAME)TrapFrame->Sp - 1;

        __try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

            ExProbeAlignment(StackFrame, sizeof(PENCLAVE_DISPATCH_FRAME), PROBE_ALIGNMENT(PENCLAVE_DISPATCH_FRAME));

#endif

            WritePointerToUser(&StackFrame->ParameterAddress, (PVOID)(ULONG_PTR)TrapFrame->X3);
            WritePointerToUser(&StackFrame->OriginalReturn, (PVOID)(ULONG_PTR)TrapFrame->Pc);
            WritePointerToUser(&StackFrame->OriginalFramePointer, (PVOID)(ULONG_PTR)TrapFrame->Fp);
            TrapFrame->Sp = (ULONG_PTR)StackFrame;
            TrapFrame->Fp = (ULONG_PTR)StackFrame;

        } __except (EXCEPTION_EXECUTE_HANDLER) {
            return GetExceptionCode();
        }
    }

#else

#error "Unsupported platform"

#endif

    //
    // Update the dispatch stack frame with linkage to the caller's stack
    // frame.
    //

    if (ReturnAddress != 0) {

        __try {

#if defined(_AMD64_)

            StackFrame = (PENCLAVE_DISPATCH_FRAME)TrapFrame->Rsp;

#elif defined(_ARM64_)

            StackFrame = (PENCLAVE_DISPATCH_FRAME)TrapFrame->Sp;

#endif

            WritePointerToUser(&StackFrame->FramePointer, (PVOID)FramePointer);
            WritePointerToUser(&StackFrame->ReturnAddress, (PVOID)ReturnAddress);

        } __except (EXCEPTION_EXECUTE_HANDLER) {
            return GetExceptionCode();
        }
    }

    //
    // Inject parameters and change user execution to the dispatcher function.
    //

#if defined(_AMD64_)

    TrapFrame->Rcx = CallingEnclaveNumber;
    TrapFrame->Rdx = (ULONG_PTR)EnclaveFunction;
    TrapFrame->R8 = FlagsOrStatus;
    TrapFrame->R9 = Parameter;
    TrapFrame->Rip = (ULONG_PTR)DispatchFunction;
    TrapFrame->SegCs = KGDT64_R3_CODE | RPL_MASK;
    NT_ASSERT(TrapFrame->Rip == SANITIZE_VA(TrapFrame->Rip,
                                            TrapFrame->SegCs,
                                            UserMode));

#elif defined(_ARM64_)

    //
    // Note that CallingEnclaveNumber cannot be saved in X0 because
    // it is reserved for passing the return value
    //

    TrapFrame->X4 = CallingEnclaveNumber;
    TrapFrame->X1 = (ULONG_PTR)EnclaveFunction;
    TrapFrame->X2 = FlagsOrStatus;
    TrapFrame->X3 = Parameter;
    TrapFrame->Pc = (ULONG_PTR)DispatchFunction;
    NT_ASSERT(TrapFrame->Pc == SANITIZE_VA(TrapFrame->Pc, UserMode));

#endif

    return STATUS_SUCCESS;
}

NTSTATUS
RtlPrepareEnclaveCall (
    _In_ PVOID ThreadTrapFrame,
    _In_ PULONG_PTR ParameterAddress,
    _In_ PVOID CallReturnAddress,
    _In_ PVOID DispatchReturnAddress,
    _In_ BOOLEAN ThreadUserShadowStacksEnabled,
    _Out_ PULONG_PTR ReturnAddress,
    _Out_ PULONG_PTR FramePointer
    )
{
    PVOID *StackPointer;
    PKTRAP_FRAME TrapFrame;
#if defined(_AMD64_)
    PVOID Address;
#endif

#if !defined(_AMD64_)

    UNREFERENCED_PARAMETER(ThreadUserShadowStacksEnabled);

    NT_ASSERT(ThreadUserShadowStacksEnabled == FALSE);

#endif

    TrapFrame = ThreadTrapFrame;

    //
    // Adjust the caller's return address to the point where it called the
    // syscall dispatcher, so that the unified call stack can contain only
    // properly constructed nested stack frames.  Only two invocation points
    // are supported: RtlCallEnclave and RtlEnclaveCallDispatcher.
    //

#if defined(_AMD64_)

    StackPointer = (PVOID *)TrapFrame->Rsp;

    __try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

        ProbeForWritePointer(StackPointer);

#endif

        //
        // Brought in here to check mode and appropriately read the pointer.
        //

        Address = ReadPointerFromMode(StackPointer, KeGetPreviousMode());

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

    //
    // Move the return parameters into the trap frame so they are available
    // then the call returns.
    //

    TrapFrame->R9 = (ULONG_PTR)ParameterAddress;

    //
    // Capture the caller's stack linkage for debugger purposes.
    //

    *ReturnAddress = TrapFrame->Rip;
    *FramePointer = TrapFrame->Rbp;

#elif defined(_ARM64_)

    StackPointer = (PVOID *)TrapFrame->Sp;

    __try {

#if !defined(VSM_ENCLAVE_RUNTIME) && !defined(TRUSTEDAPP_RUNTIME)

        ProbeForWritePointer(StackPointer);

#endif

        if (((PVOID)TrapFrame->Lr == CallReturnAddress) ||
            ((PVOID)TrapFrame->Lr == DispatchReturnAddress)) {

            TrapFrame->Pc = TrapFrame->Lr;
            NT_ASSERT(TrapFrame->Pc == SANITIZE_VA(TrapFrame->Pc,
                                                   UserMode));

        } else {
            return STATUS_INVALID_PARAMETER;
        }

    } __except (EXCEPTION_EXECUTE_HANDLER) {
        return GetExceptionCode();
    }

    //
    // Move the return parameters into the trap frame so they are available
    // then the call returns.
    //

    TrapFrame->X3 = (ULONG_PTR)ParameterAddress;

    //
    // Capture the caller's stack linkage for debugger purposes.
    //

    *ReturnAddress = TrapFrame->Pc;
    *FramePointer = TrapFrame->Fp;

#endif

    return STATUS_SUCCESS;
}

#endif // NT_IUM || IUM_SECUREKERNEL || VSM_ENCLAVE_RUNTIME || TRUSTEDAPP_RUNTIME

#if defined(VSM_ENCLAVE_RUNTIME) || defined(IUM_SECUREKERNEL) || defined(TRUSTEDAPP_RUNTIME)

NTSTATUS
RtlGetImageEnclaveConfig (
    _In_ PVOID ImageBaseAddress,
    _Out_ PIMAGE_ENCLAVE_CONFIG ReturnedEnclaveConfig
    )
{
    ULONG ActualConfigSize;
    PIMAGE_ENCLAVE_CONFIG EnclaveConfig;
    ULONG EnclaveConfigOffset;
    PIMAGE_LOAD_CONFIG_DIRECTORY LoadConfig;
    ULONG MinimumConfigSize;
    PIMAGE_NT_HEADERS NtHeader;
    NTSTATUS Status;

    Status = RtlImageNtHeaderEx(RTL_IMAGE_NT_HEADER_EX_FLAG_NO_RANGE_CHECK,
                                ImageBaseAddress,
                                0,
                                &NtHeader);
    if (!NT_SUCCESS(Status)) {
        return Status;
    }

    Status = STATUS_INVALID_IMAGE_FORMAT;

    __try {

        //
        // Find the load config for the image.
        //

        LoadConfig = LdrImageDirectoryEntryToLoadConfig(ImageBaseAddress);
        if (LoadConfig == NULL) {
            __leave;
        }

        //
        // Verify that the load config is large enough to hold a pointer to
        // the enclave configuration.
        //

        if (LoadConfig->Size < RTL_SIZEOF_THROUGH_FIELD(IMAGE_LOAD_CONFIG_DIRECTORY,
                                                        EnclaveConfigurationPointer)) {
            __leave;
        }

        //
        // Locate the enclave config and verify that it is within the bounds
        // of the image.
        //

        EnclaveConfig = (PIMAGE_ENCLAVE_CONFIG)LoadConfig->EnclaveConfigurationPointer;
        EnclaveConfigOffset = (ULONG)((ULONG_PTR)EnclaveConfig -
                                      (ULONG_PTR)ImageBaseAddress);

        if (((ULONG_PTR)ImageBaseAddress + EnclaveConfigOffset != (ULONG_PTR)EnclaveConfig) ||
            (EnclaveConfigOffset == 0) ||
            (EnclaveConfigOffset >= NtHeader->OptionalHeader.SizeOfImage) ||
            (EnclaveConfigOffset + RTL_SIZEOF_THROUGH_FIELD(IMAGE_ENCLAVE_CONFIG, Size) < EnclaveConfigOffset) ||
            (EnclaveConfigOffset + RTL_SIZEOF_THROUGH_FIELD(IMAGE_ENCLAVE_CONFIG, Size) > NtHeader->OptionalHeader.SizeOfImage) ||
            (EnclaveConfigOffset + EnclaveConfig->Size < EnclaveConfigOffset) ||
            (EnclaveConfigOffset + EnclaveConfig->Size >= NtHeader->OptionalHeader.SizeOfImage)) {

            __leave;
        }

        if (EnclaveConfig->Size < RTL_SIZEOF_THROUGH_FIELD(IMAGE_ENCLAVE_CONFIG, Size)) {
            __leave;
        }

        //
        // Determine the minimum config size that this enclave expects its
        // loader to support.
        //

        MinimumConfigSize = 0;
        if (EnclaveConfig->Size >= RTL_SIZEOF_THROUGH_FIELD(IMAGE_ENCLAVE_CONFIG, MinimumRequiredConfigSize)) {
            MinimumConfigSize = EnclaveConfig->MinimumRequiredConfigSize;
        }
        if (MinimumConfigSize < (ULONG)FIELD_OFFSET(IMAGE_ENCLAVE_CONFIG, MinimumRequiredConfigSize)) {
            MinimumConfigSize = FIELD_OFFSET(IMAGE_ENCLAVE_CONFIG, MinimumRequiredConfigSize);
        }

        //
        // Verify that this enclave does not specify more configuration
        // information than expected.
        //

        if (MinimumConfigSize > sizeof(IMAGE_ENCLAVE_CONFIG)) {
            __leave;
        }

        //
        // Capture the contents of the enclave config, and pad any remainder
        // with zeroes.
        //

        ActualConfigSize = EnclaveConfig->Size;

        if (ActualConfigSize > sizeof(IMAGE_ENCLAVE_CONFIG)) {
            ActualConfigSize = sizeof(IMAGE_ENCLAVE_CONFIG);
        }

        RtlCopyMemory(ReturnedEnclaveConfig,
                      EnclaveConfig,
                      ActualConfigSize);

        if (ActualConfigSize < sizeof(IMAGE_ENCLAVE_CONFIG)) {
            RtlZeroMemory((PUCHAR)ReturnedEnclaveConfig + ActualConfigSize,
                          sizeof(IMAGE_ENCLAVE_CONFIG) - ActualConfigSize);
        }

        Status = STATUS_SUCCESS;

    } __except (EXCEPTION_EXECUTE_HANDLER) {
        Status = GetExceptionCode();
    }

    return Status;
}

#endif // VSM_ENCLAVE_RUNTIME || IUM_SECUREKERNEL || TRUSTEDAPP_RUNTIME

#if defined(IUM_SECUREKERNEL)

#define ENCLAVE_TOKEN_FIELD_HEX_STRING  0
#define ENCLAVE_TOKEN_FIELD_BOOLEAN     1
#define ENCLAVE_TOKEN_FIELD_INT32       2
#define ENCLAVE_TOKEN_FIELD_INT64       3

#define ENCLAVE_TOKEN_FIELD_MEASUREMENT     0
#define ENCLAVE_TOKEN_FIELD_FAMILY_ID       1
#define ENCLAVE_TOKEN_FIELD_IMAGE_ID        2
#define ENCLAVE_TOKEN_FIELD_ENCLAVE_SIZE    3
#define ENCLAVE_TOKEN_FIELD_SVN             4
#define ENCLAVE_TOKEN_FIELD_ALLOW_DEBUG     5

BOOLEAN
RtlpCheckEnclaveName (
    _In_ PCHAR TokenStart,
    _In_ SIZE_T TokenLength,
    _In_ PCSTR Keyword
    )
{
    SIZE_T Length;

    Length = strlen(Keyword);
    if (TokenLength != Length) {
        return FALSE;
    }
    if (RtlCompareMemory(TokenStart, Keyword, Length) == Length) {
        return TRUE;
    }
    return FALSE;
}

NTSTATUS
RtlpHandleEnclaveTokenName (
    _In_ PCHAR TokenStart,
    _In_ SIZE_T TokenLength,
    _Out_ PULONG FieldId,
    _Out_ PULONG FieldType
    )
{
    if (RtlpCheckEnclaveName(TokenStart,
                             TokenLength,
                             "EnclaveMeasurement") != FALSE) {

        *FieldId = ENCLAVE_TOKEN_FIELD_MEASUREMENT;
        *FieldType = ENCLAVE_TOKEN_FIELD_HEX_STRING;

    } else if (RtlpCheckEnclaveName(TokenStart,
                                    TokenLength,
                                    "FamilyID") != FALSE) {

        *FieldId = ENCLAVE_TOKEN_FIELD_FAMILY_ID;
        *FieldType = ENCLAVE_TOKEN_FIELD_HEX_STRING;

    } else if (RtlpCheckEnclaveName(TokenStart,
                                    TokenLength,
                                    "ImageID") != FALSE) {

        *FieldId = ENCLAVE_TOKEN_FIELD_IMAGE_ID;
        *FieldType = ENCLAVE_TOKEN_FIELD_HEX_STRING;

    } else if (RtlpCheckEnclaveName(TokenStart,
                                    TokenLength,
                                    "EnclaveSize") != FALSE) {

        *FieldId = ENCLAVE_TOKEN_FIELD_ENCLAVE_SIZE;
        *FieldType = ENCLAVE_TOKEN_FIELD_INT64;

    } else if (RtlpCheckEnclaveName(TokenStart,
                                    TokenLength,
                                    "EnclaveSvn") != FALSE) {

        *FieldId = ENCLAVE_TOKEN_FIELD_SVN;
        *FieldType = ENCLAVE_TOKEN_FIELD_INT32;

    } else if (RtlpCheckEnclaveName(TokenStart,
                                    TokenLength,
                                    "AllowDebug") != FALSE) {

        *FieldId = ENCLAVE_TOKEN_FIELD_ALLOW_DEBUG;
        *FieldType = ENCLAVE_TOKEN_FIELD_BOOLEAN;

    } else {
        return STATUS_INVALID_IMAGE_FORMAT;
    }

    return STATUS_SUCCESS;
}

NTSTATUS
RtlpHandleEnclaveValueString (
    _In_ PCHAR TokenStart,
    _In_ SIZE_T TokenLength,
    _Inout_ PRTL_ENCLAVE_LAUNCH_TOKEN LaunchToken,
    _In_ ULONG FieldId,
    _In_ ULONG FieldType
    )
{
    UCHAR Byte;
    ULONG Index;
    ULONG MaximumLength;
    PUCHAR Value;

    //
    // A string type must be expected.
    //

    if (FieldType != ENCLAVE_TOKEN_FIELD_HEX_STRING) {
        return STATUS_INVALID_IMAGE_FORMAT;
    }

    //
    // Determine the maximum allowable length for this field.
    //

    switch (FieldId) {
    default:
        NT_ASSERT(FieldId == ENCLAVE_TOKEN_FIELD_MEASUREMENT);
        Value = LaunchToken->Measurement;
        MaximumLength = ENCLAVE_LONG_ID_LENGTH;
        break;
    case ENCLAVE_TOKEN_FIELD_FAMILY_ID:
        Value = LaunchToken->FamilyId;
        MaximumLength = ENCLAVE_SHORT_ID_LENGTH;
        break;
    case ENCLAVE_TOKEN_FIELD_IMAGE_ID:
        Value = LaunchToken->ImageId;
        MaximumLength = ENCLAVE_SHORT_ID_LENGTH;
        break;
    }

    //
    // Verify that the input string length is reasonable.
    //

    if (((TokenLength & 1) != 0) ||
        (TokenLength / 2 > MaximumLength)) {

        return STATUS_INVALID_IMAGE_FORMAT;
    }

    //
    // Parse the string contents.
    //

    while (TokenLength != 0) {
        for (Index = 0; Index < 2; Index += 1) {
            switch (TokenStart[Index]) {
            case '0':
            case '1':
            case
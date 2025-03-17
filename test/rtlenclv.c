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

            ProbeForWriteSmallStructure(StackFrame,
                                        sizeof(PENCLAVE_DISPATCH_FRAME),
                                        PROBE_ALIGNMENT(PENCLAVE_DISPATCH_FRAME));

#endif

            StackFrame->ParameterAddress = (PULONG_PTR)TrapFrame->X3;
            StackFrame->OriginalReturn = (PVOID)TrapFrame->Pc;
            StackFrame->OriginalFramePointer = (PVOID)TrapFrame->Fp;
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

            StackFrame->FramePointer = (PVOID)FramePointer;
            StackFrame->ReturnAddress = (PVOID)ReturnAddress;

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
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                Byte = TokenStart[Index] - '0';
                break;
            case 'A':
            case 'B':
            case 'C':
            case 'D':
            case 'E':
            case 'F':
                Byte = TokenStart[Index] - 'A' + 10;
                break;
            case 'a':
            case 'b':
            case 'c':
            case 'd':
            case 'e':
            case 'f':
                Byte = TokenStart[Index] - 'a' + 10;
                break;
            default:
                return STATUS_INVALID_IMAGE_FORMAT;
            }

            if (Index == 0) {
                *Value = Byte << 4;
            } else {
                *Value |= Byte;
            }
        }

        Value += 1;
        TokenStart += 2;
        TokenLength -= 2;
    }

    return STATUS_SUCCESS;
}

NTSTATUS
RtlpHandleEnclaveValueToken (
    _In_ PCHAR TokenStart,
    _In_ SIZE_T TokenLength,
    _Inout_ PRTL_ENCLAVE_LAUNCH_TOKEN LaunchToken,
    _In_ ULONG FieldId,
    _In_ ULONG FieldType
    )
{
    ULONG Base;
    ULONG Digit;
    BOOLEAN Boolean;
    ULONGLONG Value;

    //
    // Reject all empty tokens.
    //

    if (TokenLength == 0) {
        return STATUS_INVALID_IMAGE_FORMAT;
    }

    //
    // Attempt to parse a boolean token.
    //

    if (FieldType == ENCLAVE_TOKEN_FIELD_BOOLEAN) {
        if ((TokenLength == 4) &&
            (RtlCompareMemory(TokenStart,
                              "true",
                              4) == 4)) {

            Boolean = TRUE;

        } else if ((TokenLength == 5) &&
                   (RtlCompareMemory(TokenStart,
                                     "false",
                                     5) == 5)) {

            Boolean = FALSE;

        } else {
            return STATUS_INVALID_IMAGE_FORMAT;
        }

        NT_ASSERT (FieldId == ENCLAVE_TOKEN_FIELD_ALLOW_DEBUG);
        if (Boolean != FALSE) {
            LaunchToken->PolicyFlags |= IMAGE_ENCLAVE_POLICY_DEBUGGABLE;
        }

        return STATUS_SUCCESS;
    }

    //
    // The token must be an integer.  Attempt to parse it.
    //

    Value = 0;
    Base = 10;

    if (TokenStart[0] == '0') {
        Base = 8;
        TokenStart += 1;
        TokenLength -= 1;
        if (TokenStart[0] == 'x') {
            Base = 16;
            TokenStart += 1;
            TokenLength -= 1;
        }
    }

    while (TokenLength != 0) {
        switch (*TokenStart) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            Digit = *TokenStart - '0';
            break;
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F':
            Digit = *TokenStart - 'A' + 10;
            break;
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f':
            Digit = *TokenStart - 'a' + 10;
            break;
        default:
            return STATUS_INVALID_IMAGE_FORMAT;
        }

        //
        // Reject digits not appropriate for the number base.
        //

        if (Digit >= Base) {
            return STATUS_INVALID_IMAGE_FORMAT;
        }

        //
        // Check for wraparound.
        //

        if (Value * Base < Value) {
            return STATUS_INVALID_IMAGE_FORMAT;
        }

        Value = Base * Value + Digit;

        TokenStart += 1;
        TokenLength -= 1;
    }

    //
    // Check for overflow.
    //

    if ((FieldType == ENCLAVE_TOKEN_FIELD_INT32) &&
        (Value != (ULONG)Value)) {

        return STATUS_INVALID_IMAGE_FORMAT;
    }

    switch (FieldId) {
    default:
        NT_ASSERT(FieldId == ENCLAVE_TOKEN_FIELD_ENCLAVE_SIZE);
        LaunchToken->EnclaveSize = Value;
        break;
    case ENCLAVE_TOKEN_FIELD_SVN:
        LaunchToken->EnclaveSvn = (ULONG)Value;
        break;
    }

    return STATUS_SUCCESS;
}

#define PARSE_OPEN              0
#define PARSE_WANT_NAME         1
#define PARSE_NAME_STRING       2
#define PARSE_WANT_SEPARATOR    3
#define PARSE_WANT_VALUE        4
#define PARSE_TOKEN             5
#define PARSE_VALUE_STRING      6
#define PARSE_END_ITEM          7

NTSTATUS
RtlGetEnclaveLaunchToken (
    _In_ PVOID ImageBase,
    _In_ ULONG EnclaveTokenType,
    _Out_ PRTL_ENCLAVE_LAUNCH_TOKEN LaunchToken
    )
{
    ULONG DataSize;
    ULONG FieldBit;
    ULONG FieldId;
    ULONG FieldType;
    ULONG_PTR IdPath[3];
    PIMAGE_RESOURCE_DATA_ENTRY ResourceDataEntry;
    NTSTATUS Status;
    ULONG State;
    PCHAR TokenData;
    PCHAR TokenStart;
    ULONG ValidFields;

    //
    // Find the desired ENCLAVE resource in the image.
    //

    switch (EnclaveTokenType) {
    case RTL_ENCLAVE_TOKEN_TYPE_VBS:
        IdPath[1] = (ULONG_PTR)L"VBS";
        break;
    default:
        return STATUS_INVALID_PARAMETER;
    }

    IdPath[0] = (ULONG_PTR)L"ENCLAVE";
    IdPath[2] = 0;

    Status = LdrFindResource_U(ImageBase, IdPath, 3, &ResourceDataEntry);
    if (!NT_SUCCESS(Status)) {
        return Status;
    }

    Status = LdrAccessResource(ImageBase,
                               ResourceDataEntry,
                               &TokenData,
                               &DataSize);
    if (!NT_SUCCESS(Status)) {
        return Status;
    }

    RtlZeroMemory(LaunchToken, sizeof(RTL_ENCLAVE_LAUNCH_TOKEN));

    State = PARSE_OPEN;
    TokenStart = NULL;
    ValidFields = 0;
    FieldId = 0;
    FieldType = 0;

    while (DataSize != 0) {

        //
        // Require a valid UTF-7 character.
        //

        if ((*TokenData == 0) || (*TokenData > 127)) {
            return STATUS_INVALID_IMAGE_FORMAT;
        }

        if ((State == PARSE_NAME_STRING) ||
            (State == PARSE_VALUE_STRING)) {

            //
            // If the string is terminated, then process its contents.
            // Otherwise, just accumulate data into the string.
            //

            if (*TokenData == '"') {
                if (State == PARSE_VALUE_STRING) {
                    Status = RtlpHandleEnclaveValueString(TokenStart,
                                                          TokenData - TokenStart,
                                                          LaunchToken,
                                                          FieldId,
                                                          FieldType);
                    if (!NT_SUCCESS(Status)) {
                        return Status;
                    }
                    State = PARSE_END_ITEM;

                } else if (State == PARSE_NAME_STRING) {
                    Status = RtlpHandleEnclaveTokenName(TokenStart,
                                                        TokenData - TokenStart,
                                                        &FieldId,
                                                        &FieldType);
                    if (!NT_SUCCESS(Status)) {
                        return Status;
                    }

                    //
                    // Ensure that each token is seen only once.
                    //

                    FieldBit = 1 << FieldId;
                    if (ValidFields & FieldBit) {
                        return STATUS_INVALID_IMAGE_FORMAT;
                    }
                    ValidFields |= FieldBit;

                    State = PARSE_WANT_SEPARATOR;
                }
            }

        } else {
            switch (*TokenData) {

            case ' ':
            case '\t':
            case '\n':
            case '\r':

                //
                // Ignore all whitespace except as a token delimiter.
                //

                if (State == PARSE_TOKEN) {
                    Status = RtlpHandleEnclaveValueToken(TokenStart,
                                                         TokenData - TokenStart,
                                                         LaunchToken,
                                                         FieldId,
                                                         FieldType);
                    if (!NT_SUCCESS(Status)) {
                        return Status;
                    }
                    State = PARSE_END_ITEM;
                }

                break;

            case '{':

                //
                // This is the open marker.  Make sure it's expected.
                //

                if (State != PARSE_OPEN) {
                    return STATUS_INVALID_IMAGE_FORMAT;
                }
                State = PARSE_WANT_NAME;
                break;

            case '"':

                //
                // This begins or ends a string token.  Make sure it's
                // expected.
                //

                if (State == PARSE_WANT_VALUE) {
                    State = PARSE_VALUE_STRING;
                } else if (State == PARSE_WANT_NAME) {
                    State = PARSE_NAME_STRING;
                } else {
                    return STATUS_INVALID_IMAGE_FORMAT;
                }

                TokenStart = TokenData + 1;
                break;

            case ':':

                //
                // This is a name/value separator.  Make sure it's expected.
                //

                if (State != PARSE_WANT_SEPARATOR) {
                    return STATUS_INVALID_IMAGE_FORMAT;
                }
                State = PARSE_WANT_VALUE;
                break;

            case ',':

                //
                // This is an item separator.  Make sure it's expected.
                //

                if (State == PARSE_TOKEN) {
                    Status = RtlpHandleEnclaveValueToken(TokenStart,
                                                         TokenData - TokenStart,
                                                         LaunchToken,
                                                         FieldId,
                                                         FieldType);
                    if (!NT_SUCCESS(Status)) {
                        return Status;
                    }

                } else if (State != PARSE_END_ITEM) {
                    return STATUS_INVALID_IMAGE_FORMAT;
                }
                State = PARSE_WANT_NAME;
                break;

            case '}':

                //
                // This is the end marker.  Make sure it's expected.
                //

                if (State == PARSE_TOKEN) {
                    Status = RtlpHandleEnclaveValueToken(TokenStart,
                                                         TokenData - TokenStart,
                                                         LaunchToken,
                                                         FieldId,
                                                         FieldType);
                    if (!NT_SUCCESS(Status)) {
                        return Status;
                    }

                } else if (State != PARSE_END_ITEM) {
                    return STATUS_INVALID_IMAGE_FORMAT;
                }

                return STATUS_SUCCESS;

            default:

                //
                // All other characters must begin or continue a valid token.
                //

                if (State != PARSE_TOKEN) {
                    if (State != PARSE_WANT_VALUE) {
                        return STATUS_INVALID_IMAGE_FORMAT;
                    }

                    TokenStart = TokenData;
                    State = PARSE_TOKEN;
                }

                break;
            }
        }

        TokenData += 1;
        DataSize -= 1;
    }

    //
    // Reached the end of data without the close token, so the format is
    // invalid.
    //

    return STATUS_INVALID_IMAGE_FORMAT;
}

#endif

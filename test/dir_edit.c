/*++
Copyright (c) 1989  Microsoft Corporation

Module Name:
    dir.c

Abstract:
    This module contains the code to implement the NtQueryDirectoryFile,
    and the NtNotifyChangeDirectoryFile system services for the NT I/O system.

Author:
    Darryl E. Havens (darrylh) 21-Jun-1989

Environment:
    Kernel mode only

--*/

#include "iomgr.h"
#include <FeatureStaging-IoManager.h>

NTSTATUS
BuildQueryDirectoryIrp(
    __in  HANDLE FileHandle,
    __in_opt HANDLE Event,
    __in_opt PIO_APC_ROUTINE ApcRoutine,
    __in_opt PVOID ApcContext,
    __out PIO_STATUS_BLOCK IoStatusBlock,
    __out PVOID FileInformation,
    __in  ULONG Length,
    __in  FILE_INFORMATION_CLASS FileInformationClass,
    __in  ULONG QueryFlags,
    __in_opt PUNICODE_STRING FileName,
    __in  UCHAR MinorFunction,
    __out BOOLEAN *SynchronousIo,
    __out PDEVICE_OBJECT *DeviceObject,
    __out PIRP *Irp,
    __out PFILE_OBJECT *FileObject,
    __out KPROCESSOR_MODE *RequestorMode
    );

#pragma alloc_text(PAGE, BuildQueryDirectoryIrp)
#pragma alloc_text(PAGE, NtQueryDirectoryFile)
#pragma alloc_text(PAGE, NtQueryDirectoryFileEx)
#pragma alloc_text(PAGE, NtNotifyChangeDirectoryFile)
#pragma alloc_text(PAGE, NtNotifyChangeDirectoryFileEx)

NTSTATUS
BuildQueryDirectoryIrp(
    __in  HANDLE FileHandle,
    __in_opt HANDLE Event,
    __in_opt PIO_APC_ROUTINE ApcRoutine,
    __in_opt PVOID ApcContext,
    __out PIO_STATUS_BLOCK IoStatusBlock,
    __out PVOID FileInformation,
    __in  ULONG Length,
    __in  FILE_INFORMATION_CLASS FileInformationClass,
    __in  ULONG QueryFlags,
    __in_opt PUNICODE_STRING FileName,
    __in  UCHAR MinorFunction,
    __out BOOLEAN *SynchronousIo,
    __out PDEVICE_OBJECT *DeviceObject,
    __out PIRP *Irp,
    __out PFILE_OBJECT *FileObject,
    __out KPROCESSOR_MODE *RequestorMode
    )

/*++
Routine Description:
    This service operates on a directory file or OLE container specified by the
    FileHandle parameter.  The service returns information about files in the
    directory or embeddings and streams in the container specified by the file
    handle.  The ReturnSingleEntry parameter specifies that only a single entry
    should be returned rather than filling the buffer.  The actual number of
    files whose information is returned, is the smallest of the following:
        o  One entry, if the ReturnSingleEntry parameter is TRUE.
        o  The number of entries whose information fits into the specified
           buffer.
        o  The number of entries that exist.
        o  One entry if the optional FileName parameter is specified.
    If the optional FileName parameter is specified, then the only information
    that is returned is for that single entries, if it exists.  Note that the
    file name may not specify any wildcard characters according to the naming
    conventions of the target file system.  The ReturnSingleEntry parameter is
    simply ignored.
    The information that is obtained about the entries in the directory or OLE
    container is based on the FileInformationClass parameter.  Legal values are
    hard coded based on the MinorFunction.
Arguments:
    FileHandle - Supplies a handle to the directory file or OLE container for
        which information should be returned.
    Event - Supplies an optional event to be set to the Signaled state when
        the query is complete.
    ApcRoutine - Supplies an optional APC routine to be executed when the
        query is complete.
    ApcContext - Supplies a context parameter to be passed to the ApcRoutine,
        if an ApcRoutine was specified.
    IoStatusBlock - Address of the caller's I/O status block.
    FileInformation - Supplies a buffer to receive the requested information
        returned about the contents of the directory.
    Length - Supplies the length, in bytes, of the FileInformation buffer.
    FileInformationClass - Specfies the type of information that is to be
        returned about the files in the specified directory or OLE container.
    QueryFlags - One or more of the flags contained in SL_QUERY_DIRECTORY_MASK.
    FileName - Optionally supplies a file name within the specified directory
        or OLE container.
    MinorFunction - IRP_MN_QUERY_DIRECTORY or IRP_MN_QUERY_OLE_DIRECTORY
    SynchronousIo - pointer to returned BOOLEAN; TRUE if synchronous I/O
    DeviceObject - pointer to returned pointer to device object
    Irp - pointer to returned pointer to device object
    FileObject - pointer to returned pointer to file object
    RequestorMode - pointer to returned requestor mode
Return Value:
    The status returned is STATUS_SUCCESS if a valid irp was created for the
    query operation.
--*/

{
    PIRP irp;
    NTSTATUS status;
    PFILE_OBJECT fileObject;
    PDEVICE_OBJECT deviceObject;
    PKEVENT eventObject = (PKEVENT) NULL;
    KPROCESSOR_MODE requestorMode;
    PCHAR auxiliaryBuffer = (PCHAR) NULL;
    PIO_STACK_LOCATION irpSp;
    PMDL mdl;
    PETHREAD CurrentThread;

    PAGED_CODE();

    //
    // Get the previous mode;  i.e., the mode of the caller.
    //

    CurrentThread = PsGetCurrentThread ();
    requestorMode = KeGetPreviousModeByThread(&CurrentThread->Tcb);
    *RequestorMode = requestorMode;

    __try {

        if (requestorMode != KernelMode) {

            ULONG operationlength = 0;  // assume invalid

            //
            // The caller's access mode is not kernel so probe and validate
            // each of the arguments as necessary.  If any failures occur,
            // the condition handler will be invoked to handle them.  It
            // will simply cleanup and return an access violation status
            // code back to the system service dispatcher.
            //

            //
            // The IoStatusBlock parameter must be writeable by the caller.
            //

            ProbeForWriteIoStatus(IoStatusBlock);

            // Ensure that the FileInformationClass parameter is legal for
            // querying information about files in the directory or object.

            if (FileInformationClass == FileDirectoryInformation) {
                operationlength = sizeof(FILE_DIRECTORY_INFORMATION);
            } else if (MinorFunction == IRP_MN_QUERY_DIRECTORY) {
                switch (FileInformationClass)
                {
                    case FileFullDirectoryInformation:
                        operationlength = sizeof(FILE_FULL_DIR_INFORMATION);
                        break;
                    case FileIdFullDirectoryInformation:
                        operationlength = sizeof(FILE_ID_FULL_DIR_INFORMATION);
                        break;
                    case FileBothDirectoryInformation:
                        operationlength = sizeof(FILE_BOTH_DIR_INFORMATION);
                        break;
                    case FileIdBothDirectoryInformation:
                        operationlength = sizeof(FILE_ID_BOTH_DIR_INFORMATION);
                        break;
                    case FileNamesInformation:
                        operationlength = sizeof(FILE_NAMES_INFORMATION);
                        break;
                    case FileObjectIdInformation:
                        operationlength = sizeof(FILE_OBJECTID_INFORMATION);
                        break;
                    case FileQuotaInformation:
                        operationlength = sizeof(FILE_QUOTA_INFORMATION);
                        break;
                    case FileReparsePointInformation:
                        operationlength = sizeof(FILE_REPARSE_POINT_INFORMATION);
                        break;
                    case FileIdGlobalTxDirectoryInformation:
                        operationlength = sizeof(FILE_ID_GLOBAL_TX_DIR_INFORMATION);
                        break;
                    case FileIdExtdDirectoryInformation:
                        operationlength = sizeof(FILE_ID_EXTD_DIR_INFORMATION);
                        break;
                    case FileIdExtdBothDirectoryInformation:
                        operationlength = sizeof(FILE_ID_EXTD_BOTH_DIR_INFORMATION);
                        break;
                    case FileId64ExtdDirectoryInformation:
                        operationlength = sizeof(FILE_ID_64_EXTD_DIR_INFORMATION);
                        break;
                    case FileId64ExtdBothDirectoryInformation:
                        operationlength = sizeof(FILE_ID_64_EXTD_BOTH_DIR_INFORMATION);
                        break;
                    case FileIdAllExtdDirectoryInformation:
                        operationlength = sizeof(FILE_ID_ALL_EXTD_DIR_INFORMATION);
                        break;
                    case FileIdAllExtdBothDirectoryInformation:
                        operationlength = sizeof(FILE_ID_ALL_EXTD_BOTH_DIR_INFORMATION);
                        break;
                }
            }

            //
            // If the FileInformationClass parameter is illegal, fail now.
            //

            if (operationlength == 0) {
                return STATUS_INVALID_INFO_CLASS;
            }

            //
            // Ensure that the caller's supplied buffer is at least large enough
            // to contain the fixed part of the structure required for this
            // query.
            //

            if (Length < operationlength) {
                return STATUS_INFO_LENGTH_MISMATCH;
            }

            //
            // The FileInformation buffer must be writeable by the caller.
            //
            // The alignment rules for FileInformation depend on the
            // architecture:
            // x86 - Always sizeof(ULONG), even when under WoW;
            // other - IopQuerySetAlignmentRequirement[FileInformationClass]
            //

#if !defined(_WIN64)

            ProbeForWrite(FileInformation, Length, sizeof(ULONG));

#else

#if BUILD_WOW64_ENABLED && !XBOX_WOW64_DISABLED

            if (PS_IS_WOW_RELAXED_ALIGNMENT_PROC(PsGetCurrentProcessByThread(CurrentThread))) {
                ProbeForWrite(FileInformation, Length, sizeof(ULONG));

            } else

#endif

            {
                ProbeForWrite(FileInformation,
                              Length,
                              IopQuerySetAlignmentRequirement[FileInformationClass]);
            }

#endif // BUILD_WOW64_ENABLED && !XBOX_WOW64_DISABLED

        }

    } __except (UmaExceptionFilter(requestorMode)) {
        return GetExceptionCode();
    }

    //
    // If the optional FileName parameter was specified, then it must be
    // readable by the caller.  Capture the file name string in a pool
    // block.  Note that if an error occurs during the copy, the cleanup
    // code in the exception handler will deallocate the pool before
    // returning an access violation status.
    //

    if (ARGUMENT_PRESENT(FileName)) {

        UNICODE_STRING fileName;
        PUNICODE_STRING nameBuffer;

        //
        // Capture the string descriptor itself to ensure that the
        // string is readable by the caller without the caller being
        // able to change the memory while its being checked.
        //

        if (requestorMode != KernelMode) {
            fileName = ProbeAndReadUnicodeStringEx(FileName);
        } else {
            fileName = *FileName;
        }

        //
        // If the length is not an even number of bytes
        // return an error.
        //

        if (fileName.Length & (sizeof(WCHAR) - 1)) {
            return STATUS_INVALID_PARAMETER;
        }

        if (fileName.Length) {

            //
            // The length of the string is non-zero, so probe the
            // buffer described by the descriptor if the caller was
            // not kernel mode.  Likewise, if the caller's mode was
            // not kernel, then check the length of the name string
            // to ensure that it is not too long.
            //

            if (requestorMode != KernelMode) {
                ProbeForRead(fileName.Buffer,
                             fileName.Length,
                             sizeof(UCHAR));

                // account for unicode

                if (fileName.Length >= MAXIMUM_FILENAME_LENGTH << 1) {
                    ExRaiseStatus(STATUS_INVALID_PARAMETER);
                }
            }

            //
            // Allocate an auxiliary buffer large enough to contain
            // a file name descriptor and to hold the entire file
            // name itself.  Copy the body of the string into the
            // buffer.
            //

            auxiliaryBuffer = ExAllocatePool2(
                                POOL_FLAG_NON_PAGED | POOL_FLAG_USE_QUOTA,
                                fileName.Length + sizeof(UNICODE_STRING),
                                'iDoI'
                              );

            if (!auxiliaryBuffer) {
                return STATUS_INSUFFICIENT_RESOURCES;
            }

            __try {
                RtlCopyMemory(auxiliaryBuffer + sizeof(UNICODE_STRING),
                              fileName.Buffer,
                              fileName.Length);

                // Finally, build the Unicode string descriptor in the auxiliary buffer.

                nameBuffer = (PUNICODE_STRING)auxiliaryBuffer;
                nameBuffer->Length = fileName.Length;
                nameBuffer->MaximumLength = fileName.Length;
                nameBuffer->Buffer = (PWSTR)(auxiliaryBuffer + sizeof(UNICODE_STRING));

            } __except (UmaExceptionFilter(requestorMode)) {
                ExFreePool(auxiliaryBuffer);
                return GetExceptionCode();
            }
        }
    }

    //
    // There were no blatant errors so far, so reference the file object so
    // the target device object can be found.  Note that if the handle does
    // not refer to a file object, or if the caller does not have the required
    // access to the file, then it will fail.
    //

    status = IopReferenceFileObject(FileHandle,
                                    FILE_LIST_DIRECTORY,
                                    requestorMode,
                                    &fileObject,
                                    NULL);
    if (!NT_SUCCESS(status)) {
        if (auxiliaryBuffer) {
            ExFreePool(auxiliaryBuffer);
        }
        return status;
    }
    *FileObject = fileObject;

    //
    // If this file has an I/O completion port associated w/it, then ensure
    // that the caller did not supply an APC routine, as the two are mutually
    // exclusive methods for I/O completion notification.
    //

    if (fileObject->CompletionContext && IopApcRoutinePresent(ApcRoutine)) {
        ObDereferenceObject(fileObject);
        if (auxiliaryBuffer) {
            ExFreePool(auxiliaryBuffer);
        }
        return STATUS_INVALID_PARAMETER;
    }

    //
    // Get the address of the event object and set the event to the Not-
    // Signaled state, if an event was specified.  Note here, too, that if
    // the handle does not refer to an event, or if the event cannot be
    // written, then the reference will fail.
    //

    if (ARGUMENT_PRESENT(Event)) {
        status = ObReferenceObjectByHandle(Event,
                                           EVENT_MODIFY_STATE,
                                           ExEventObjectType,
                                           requestorMode,
                                           (PVOID *)&eventObject,
                                           (POBJECT_HANDLE_INFORMATION)NULL);
        if (!NT_SUCCESS(status)) {
            if (auxiliaryBuffer) {
                ExFreePool(auxiliaryBuffer);
            }
            ObDereferenceObject(fileObject);
            return status;
        } else {

#pragma prefast(suppress : __WARNING_DEREF_NULL_PTR, "Event object cannot be null otherwise status above would be STATUS_NO_MEMORY")
            KeResetEvent(eventObject);
        }
    }

    //
    // Make a special check here to determine whether this is a synchronous
    // I/O operation.  If it is, then wait here until the file is owned by
    // the current thread.
    //

    if (fileObject->Flags & FO_SYNCHRONOUS_IO) {

        BOOLEAN interrupted;

        status = IopAcquireFileObjectLock(fileObject,
                                          requestorMode,
                                          (BOOLEAN)((fileObject->Flags & FO_ALERTABLE_IO) != 0),
                                          &interrupted);
        if (interrupted) {
            if (auxiliaryBuffer != NULL) {
                ExFreePool(auxiliaryBuffer);
            }
            if (eventObject != NULL) {
                ObDereferenceObject(eventObject);
            }
            ObDereferenceObject(fileObject);
            return status;
        }
        *SynchronousIo = TRUE;
    } else {
        *SynchronousIo = FALSE;

#if BUILD_WOW64_ENABLED && defined(_WIN64) && !XBOX_WOW64_DISABLED

        if (requestorMode != KernelMode) {
            __try {
                // If this is a 32-bit asynchronous IO, then mark the Iosb being sent as so.
                // Note: IopMarkApcRoutineIfAsynchronousIo32 must be called after probing
                //       the IoStatusBlock structure for write.
                IopMarkApcRoutineIfAsynchronousIo32(&IoStatusBlock,
                                                    &ApcRoutine,
                                                    FALSE);
            } __except (UmaExceptionFilter(requestorMode)) {
                IopAllocateIrpCleanup(fileObject, eventObject);
                if (auxiliaryBuffer) {
                    ExFreePool(auxiliaryBuffer);
                }
                return GetExceptionCode();
            }
        }

#endif // BUILD_WOW64_ENABLED && defined(_WIN64) && !XBOX_WOW64_DISABLED
    }

    //
    // Set the file object to the Not-Signaled state.
    //

    IopResetEvent(fileObject);

    //
    // Get the address of the target device object.
    //

    deviceObject = IoGetRelatedDeviceObject(fileObject);
    *DeviceObject = deviceObject;

    //
    // Allocate and initialize the I/O Request Packet (IRP) for this operation.
    // The allocation is performed with an exception handler in case the
    // caller does not have enough quota to allocate the packet.
    irp = IopAllocateIrp(deviceObject, deviceObject->StackSize, !(*SynchronousIo));
    if (!irp) {
        IopAllocateIrpCleanup(fileObject, eventObject);
        if (auxiliaryBuffer) {
            ExFreePool(auxiliaryBuffer);
        }
        return STATUS_INSUFFICIENT_RESOURCES;
    }
    *Irp = irp;

    irp->Tail.Overlay.OriginalFileObject = fileObject;
    irp->Tail.Overlay.Thread = CurrentThread;
    irp->RequestorMode = requestorMode;

    //
    // Fill in the service independent parameters in the IRP.
    //

    irp->UserEvent = eventObject;
    irp->UserIosb = IoStatusBlock;
    irp->Overlay.AsynchronousParameters.UserApcRoutine = ApcRoutine;
    irp->Overlay.AsynchronousParameters.UserApcContext = ApcContext;

    //
    // Get a pointer to the stack location for the first driver.  This will be
    // used to pass the original function codes and parameters.
    //

    irpSp = IoGetNextIrpStackLocation(irp);
    irpSp->MajorFunction = IRP_MJ_DIRECTORY_CONTROL;
    irpSp->MinorFunction = MinorFunction;
    irpSp->FileObject = fileObject;

    // Also, copy the caller's parameters to the service-specific portion of
    // the IRP.
    //

    irp->Tail.Overlay.AuxiliaryBuffer =
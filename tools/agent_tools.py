import subprocess
import os

def compile_fstar_code(code_str, file_name="temp.fst"):
    """
    Compiles a given F* code string using fstar.exe.

    :param code_str: The F* code as a string.
    :param file_name: The name of the .fst file to create.
    :return: The output from the fstar.exe compilation process.
    """
    # Write the code to a .fst file
    with open(file_name, 'w') as f:
        f.write(code_str)

    # Get the path to fstar.exe from the environment variable
    fstar_path = os.getenv('FSTAR_PATH')
    if not fstar_path:
        raise EnvironmentError("FSTAR_PATH environment variable is not set.")

    # Compile the .fst file using fstar.exe
    try:
        result = subprocess.run([fstar_path, file_name], capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"An error occurred: {e.stderr}"

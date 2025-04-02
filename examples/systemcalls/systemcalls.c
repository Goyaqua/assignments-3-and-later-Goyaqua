#include "systemcalls.h"
#include <stdio.h>      // perror()
#include <stdbool.h>    // bool, true, false
#include <stdarg.h>     // va_list, va_start, va_end
#include <stdlib.h>     // exit(), system()
#include <unistd.h>     // fork(), execv(), dup2(), close()
#include <sys/types.h>  // pid_t
#include <sys/wait.h>   // waitpid(), WIFEXITED, WEXITSTATUS
#include <fcntl.h>      // open(), O_WRONLY, O_CREAT, O_TRUNC

/**
 * @param cmd the command to execute with system()
 * @return true if the command in @param cmd was executed
 *   successfully using the system() call, false if an error occurred,
 *   either in invocation of the system() call, or if a non-zero return
 *   value was returned by the command issued in @param cmd.
*/
bool do_system(const char *cmd)
{

    if (cmd == NULL) {
        return false;
    }

    int ret = system(cmd);

    if (ret == -1) {
        return false;
    }

    return WIFEXITED(ret) && WEXITSTATUS(ret) == 0;
}

/**
* @param count -The numbers of variables passed to the function. The variables are command to execute.
*   followed by arguments to pass to the command
*   Since exec() does not perform path expansion, the command to execute needs
*   to be an absolute path.
* @param ... - A list of 1 or more arguments after the @param count argument.
*   The first is always the full path to the command to execute with execv()
*   The remaining arguments are a list of arguments to pass to the command in execv()
* @return true if the command @param ... with arguments @param arguments were executed successfully
*   using the execv() call, false if an error occurred, either in invocation of the
*   fork, waitpid, or execv() command, or if a non-zero return value was returned
*   by the command issued in @param arguments with the specified arguments.
*/

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    va_end(args);

    pid_t pid = fork();
    int status;

    if (pid == -1) {
        return false;
    } 
    else if (pid == 0) {
        execv(command[0],command);
        perror("execv failed");
        exit(1);
    }
    else {
        if (waitpid(pid, &status, 0) == -1) {
            return false;        }
    }

    return WIFEXITED(status) && (WEXITSTATUS(status) == 0);

}

/**
* @param outputfile - The full path to the file to write with command output.
*   This file will be closed at completion of the function call.
* All other parameters, see do_exec above
*/
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;

    va_end(args);

    pid_t pid = fork();
    int status;

    if (pid == -1) {
        perror("fork");
        return false;
    } else if (pid == 0) {
        int fd = open(outputfile, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (fd < 0) {
            perror("open");
            exit(1);
        }

        if (dup2(fd, STDOUT_FILENO) < 0) {
            perror("dup2");
            close(fd);
            exit(1);
        }

        close(fd);

        execv(command[0], command);
        perror("execv");
        exit(1);
    }

    if (waitpid(pid, &status, 0) == -1) {
        perror("waitpid");
        return false;
    }

    return WIFEXITED(status) && (WEXITSTATUS(status) == 0);
}

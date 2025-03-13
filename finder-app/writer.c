#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    
    openlog("writer", LOG_PID | LOG_CONS, LOG_USER);

    // Number of arguments
    if (argc != 3) {
        syslog(LOG_ERR, "Error: TWo arguments required. %s <file_path> <text>", argv[0]);
        fprintf(stderr,"Error: TWo arguments required. %s <file_path> <text>", argv[0]);
        closelog();
        return EXIT_FAILURE;
    }

    char *file_path = argv[1];
    char *text = argv[2];

    //open file for writing
    int fd = open(file_path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        syslog(LOG_ERR, "Error opening file : %s", file_path);
        perror("open");
        closelog();
        return EXIT_FAILURE;
    }

    ssize_t bytes_written = write(fd, text, strlen(text));
    if (bytes_written == -1 ) {
        syslog(LOG_ERR, "Error writing yo file : %s", file_path);
        perror("write");
        close(fd);
        closelog();
        return EXIT_FAILURE;
    }

    syslog(LOG_DEBUG, "Writing \"%s\" to %s", text, file_path);

    close(fd);
    closelog();

    return EXIT_SUCCESS;
}
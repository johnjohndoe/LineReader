//
//  main.m
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//


/*! \mainpage Line Reader
 * \author Tobias Preuss
 * \date 2010.10
 *
 * \section Description
 *
 * <p>This application implements functions to read forwards or backwards from files.
 * The NSData class is used to handle the binary data within the file.</p>
 *
 * \section Configuration
 * <p>The source path, number of maximum lines and reading direction can be changed 
 * in the user interface.</p>
 */



#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc,  (const char **) argv);
}

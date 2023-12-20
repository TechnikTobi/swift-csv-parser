//
//  parser.swift
//
//  Created by Tobias Prisching on 20.12.23.
//

import Foundation

extension String
{
    func
    asCSVdata
    (
        separatedBy separator: Character = ";",
        includeEmptyCells:     Bool      = true
    )
    throws
    -> [[String]]
    {
        let newlineCharacters = CharacterSet.newlines;
        let controlCharacters = CharacterSet(charactersIn: String(separator) + "\"").union(newlineCharacters);
        
        let scanner = Scanner(string: self);
        scanner.charactersToBeSkipped = nil;
        
        var csvData : [[String]] = [];
        
        while !scanner.isAtEnd
        {
            var insideQuotes        = false;
            var rowIsFinished       = false;
            var rowData             = [String]();
            var columnData          = "";
            var lastScannerPosition = scanner.currentIndex;
            
            while !rowIsFinished
            {
                if let rawString = scanner.scanUpToCharacters(from: controlCharacters)
                {
                    columnData.append(rawString);
                }
                
                if scanner.isAtEnd
                {
                    if includeEmptyCells || !columnData.isEmpty
                    {
                        rowData.append(columnData);
                    }
                    rowIsFinished = true;
                }
                else if let rawString = scanner.scanCharacters(from: newlineCharacters)
                {
                    if insideQuotes // Row NOT finished
                    {
                        columnData.append(rawString);
                    }
                    else            // Row IS finished!
                    {
                        if includeEmptyCells || !columnData.isEmpty
                        {
                            rowData.append(columnData);
                        }
                        rowIsFinished = true;
                    }
                }
                else if let _ = scanner.scanString("\"")
                {
                    if insideQuotes, let _ = scanner.scanString("\"")
                    {
                        // Replace double quotes ("") with a single quote (")
                        // in the final string.
                        columnData.append("\"");
                    }
                    else // Start/End of a quoted string.
                    {
                        insideQuotes = !insideQuotes;
                    }
                }
                else if let _ = scanner.scanString(String(separator))
                {
                    if insideQuotes // This separator is INSIDE a quoted String!
                    {
                        columnData.append(separator);
                    }
                    else            // This separator truly separates two cells!
                    {
                        rowData.append(columnData);
                        columnData.removeAll();
                        _ = scanner.scanCharacters(from: CharacterSet.whitespaces);
                    }
                }
                
                if lastScannerPosition == scanner.currentIndex
                {
                    throw CsvParsingError.scannerNotAdvancing;
                }
            }
            
            if rowData.count > 0
            {
                csvData.append(rowData);
            }
        }
        
        return csvData
    }
    
}

enum CsvParsingError: Error
{
    case scannerNotAdvancing
}

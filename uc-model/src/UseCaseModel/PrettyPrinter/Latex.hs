-----------------------------------------------------------------------------
-- |
-- Module      :  UseCaseModel.PrettyPrinter.Latex
-- Copyright   :  (c) Rodrigo Bonifacio 2008, 2009
-- License     :  LGPL
--
-- Maintainer  :  rba2@cin.ufpe.br
-- Stability   :  provisional
-- Portability :  portable
--
-- A Latex pretty printer for our Use Case Model data type. Useful for 
-- generating ps or pdf files from a use case model.
--
--
-----------------------------------------------------------------------------

module UseCaseModel.PrettyPrinter.Latex 
 (ucmToLatex, scenarioToLatex, adviceToLatex, flowToLatex, aspectInterfacesToLatex)
where 

import Text.PrettyPrint.HughesPJ

import UseCaseModel.Types

title1 :: String
title1 = "\\title{Use Case Model Generated from "

title2 :: String
title2 = "\\title{Aspect Interfaces Generated from "

ucmToLatex :: UseCaseModel -> Doc
ucmToLatex (UCM name ucs as) = vcat [ beginDocument title1 name
                                    , ucsToLatex ucs
                                    , aspectsToLatex as
                                    , endDocument
                                    ]

aspectInterfacesToLatex :: UseCaseModel -> Doc
aspectInterfacesToLatex ucm@(UCM name ucs as) = 
    vcat [ beginDocument title2 name
         , mjpsToLatex (computeAspectInterfaces ucm)
         , endDocument
         ]

beginDocument :: String -> String -> Doc
beginDocument title name =
 vcat [ text "%This Latex file is machine-generated by the Hephaestus\n"
      , text "\\documentclass[a4paper,11pt]{article}" 
      , text "\\newcommand{\\bl}{\\\\ \\hline}"
      , text (title ++ name ++ "}")
      , text "\\begin{document}" 
      , text "\\maketitle"
      ]



ucsToLatex :: [UseCase] -> Doc 
ucsToLatex [] = empty
ucsToLatex (x:xs) = vcat ((text "\\section*{Use cases}") : (map ucToLatex (x:xs)))
 where 
   ucToLatex  uc = vcat ([ text ("\\subsection*{Use case " ++ (ucId uc) ++ "}") 
                         , text ("\\begin{itemize}") 
                         , text ("\\item {\\bf Name: }" ++ (ucName uc) )
                         , text ("\\item {\\bf Description: }" ++ (ucDescription uc))
                         , text ("\\end{itemize}" )  
                         ] ++ (map scenarioToLatex (ucScenarios uc)))

aspectsToLatex :: [AspectualUseCase] -> Doc
aspectsToLatex [] = empty
aspectsToLatex (x:xs)  = vcat ((text "\\section*{Aspectual use cases}") : (map aspectToLatex (x:xs)))
 where aspectToLatex a = vcat ([ text("\\subsection*{Aspectual use case " ++ (aspectName a) ++ "}") ] ++ (map adviceToLatex (advices a))) 

scenarioToLatex :: Scenario -> Doc
scenarioToLatex (Scenario i d f s t) = vcat ([ text ("\\subsubsection*{Scenario " ++ i ++ "}")
                                             , text ("\\begin{tabular}{p{1in}p{4in}}")
                                             , text ("{\\bf Description:} & " ++ d ++ " \\\\")
                                             , hcat(text ("{\\bf From steps:} & ") : ((punctuate (text ",") (map idRefToLatex f)) ++ [text " \\\\"]))
                                             , hcat(text ("{\\bf To steps:} & ") : ((punctuate (text "," ) (map idRefToLatex t)) ++ [text " \\\\"]))
                                             , text ("\\end{tabular}")
                                             , text (" ")
                                             ] ++ [(flowToLatex s)])

adviceToLatex :: Advice -> Doc
adviceToLatex adv =  vcat ([ text ("\\begin{tabular}{p{1in}p{4in}}")
                           , text ("{\\bf Id:} & " ++ (advId adv) ++ "\\\\" )
                           , text ("{\\bf Description} & " ++ (advDescription adv) ++ "\\\\" )
                           , text ("{\\bf Pointcut:} & " ++ (pc (advType adv)) ++ (concat (map show (pointCut adv)) ) ++ "\\\\" )
                           , text ("\\end{tabular}")
                           , text (" ")
                           ] ++ [(flowToLatex (aspectualFlow adv))])

pc :: AdviceType -> String
pc (Before) = "{\\bf BEFORE} "
pc (After)  = "{\\bf AFTER} "    
pc (Around) = "{\\bf AROUND} "

flowToLatex :: Flow -> Doc
flowToLatex [] = empty
flowToLatex (s:ss) = vcat [ text ("\\begin{tabular}{|p{0.8in}|p{1.6in}|p{1.6in}|p{1.6in}|}")
                          , text ("\\hline")
                          , text ("Id & User Action & Condition & System Response  \\bl ")
                          , vcat (map stepToLatex (s:ss))       
                          , text ("\\end{tabular}" ) 
                          ]

stepToLatex :: Step -> Doc
stepToLatex (Step i a s r an) = hcat [ text i
                                     , text " & " 
                                     , text a
                                     , text " & " 
                                     , text s 
                                     , text " & " 
                                     , text r 
                                     , text " \\bl "
                                     ]  

stepToLatex Proceed = text "\\multicolumn{5}{c}{{\\bf PROCEED}} \\bl "

idRefToLatex :: StepRef -> Doc
idRefToLatex (IdRef s) = text s
idRefToLatex (AnnotationRef s) = text ('@':s)  

mjpsToLatex :: [MatchedJoinPoint] -> Doc
mjpsToLatex [] = empty
mjpsToLatex (m:ms)  = vcat  ((text "\\section*{Matched join points}") : map mjpToLatex (m:ms)) 
 where 
  mjpToLatex m = vcat [ text ("\\subsection*{Step " ++ fst m ++ " }") 
                      , text ("\\begin{tabular}{|p{1.2in}|p{1.8in}|p{2.2in}|}")
                      , text ("\\hline")
                      , text ("Advice & Type & Pointcut \\bl ") 
                      , vcat (map advAndPointCutToLatex (snd m))
                      , text ("\\end{tabular}")
                      ]    
  advAndPointCutToLatex (a,p) = hcat [ text (advId a)
                                     , text " & "
                                     , text (pc (advType a))
                                     , text " & " 
                                     , idRefToLatex p
                                     , text " \\bl"
                                     ]

endDocument :: Doc
endDocument =  text "\\end{document}"
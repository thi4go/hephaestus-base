

module ComponentModel.Parsers.AbsComponentModel where

-- Haskell module generated by the BNF converter




newtype Ident = Ident String deriving (Eq,Ord,Show,Read)
data ComponentModel =
   TComponentModel [ComponentMapping]
  deriving (Eq,Ord,Show,Read)

data ComponentMapping =
   TComponentMapping Ident RelativePath
  deriving (Eq,Ord,Show,Read)

data RelativePath =
   BasicFilePath Ident
 | SpecialFilePath Ident RelativePath
 | BasicFilePathExt Ident Ident
 | BasicFileExt Ident
 | ComposedFilePath Ident RelativePath
  deriving (Eq,Ord,Show,Read)


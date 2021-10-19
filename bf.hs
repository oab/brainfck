module Main where

import Data.Word(Word8)
import System.Environment

charToWord8 :: Char -> Word8
charToWord8 = toEnum . fromEnum  

word8ToChar :: Word8 -> Char
word8ToChar = toEnum . fromEnum  

type RewindString = (String,String)
type State a = ([a],a,[a])

readw :: State Word8 -> Word8
readw (_,a,_) = a

writew :: State Word8 -> Word8 -> State Word8
writew (l,_,r) w = (l,w,r)

incp :: State Word8 -> State Word8
incp (l,a,[]) = (a:l,0,[])
incp (l,a,r:rs) = (a:l,r,rs)

decp :: State Word8 -> State Word8
decp ([],a,r) = ([],0,a:r)
decp (l:ls,a,r) = (ls,l,a:r)

incv :: State Word8 -> State Word8
incv (l,a,r) = (l,a+1,r)

decv :: State Word8 -> State Word8
decv (l,a,r) = (l,a-1,r)

parse :: String -> String
parse s = filter (`elem` "[]<>+-,.") s

begin :: String -> (State Word8, RewindString)
begin s = (([],0,[]),([],s))

lpb :: Word8 -> RewindString -> RewindString
lpb 0 rs = seekr rs
  where seekr (l,']':r) = (']':l,r)
        seekr (l,r:rs) = seekr (r:l,rs)
lpb _ (l,r:rs) = (r:l,rs)
  
lpe :: Word8 -> RewindString -> RewindString
lpe 0 (l,']':r) = (']':l,r)
lpe _ rs = seekl rs
  where seekl (x:'[':l,r) = ('[':l,x:r)
        seekl (x:l,rs) = seekl (l,x:rs)

type Ctx = (State Word8, RewindString)

step :: Ctx -> IO Ctx

step (s,(l,r@'.':rs)) = do
  let x = readw s
  (putChar . word8ToChar) x
  return (s,(r:l,rs))

step (s,(l,r@',':rs)) = do
  x <- getChar
  let s' = writew s (charToWord8 x)
  return (s',(r:l,rs))

step (state, input@(l,r:rs)) =  return (f state, input')
  where f = case r of
          '+' -> incv
          '-' -> decv
          '>' -> incp
          '<' -> decp
          _ -> id
        input' = case r of
          '[' -> lpb (readw state) input
          ']' -> lpe (readw state) input
          _ -> (r:l,rs)


eval :: Ctx -> IO Ctx
eval ctx@(_,(_,[])) = return ctx
eval ctx = do
  ctx' <- step ctx
  eval ctx'
  
main :: IO ()  
main = do
  args <- getArgs
  let input = head args
  s <- readFile input
  let start = begin $ parse s
  end <- eval start
  putChar '\n'  
  return ()

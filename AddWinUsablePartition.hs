-- usage: runhaskell AddWinUsablePartition.hs /dev/sdX
--
-- This will add a partition on your bootable USB thumb drive that can be used
-- by Windows. Therefore it will first remove the existing Live-Linux partition
-- then create a new partition behind the Live-Linux partition. And then will
-- recreate the Live-Linux partition with the same geometry as before.

import Control.Applicative   ((<$>))
import Control.Monad         (void)
import Data.String.Utils     (split)
import System.Environment    (getArgs)
import System.Process        (readProcess)

main :: IO ()
main = do
    device <- head <$> getArgs
    (disk, partitions) <- getDiskLayout device
    if length partitions /= 1
    then error "error: expected exactly one existing partition"
    else addPartition disk $ partitions !! 0

getDiskLayout:: String -> IO (Disk, [Partition])
getDiskLayout device = do
    out <- map (split ":") <$> lines <$> parted device ["print"]
    return ( toDisk $ out !! 1
           , map toPart $ drop 2 out
           )
    where readS = read . init
          toPart (number : start : end : _ : fs : _) =
              Partition (read number) (readS start) (readS end) fs
          toDisk (_ : size : _ : _ : _ : partTable :_) =
              Disk device (readS size) partTable

addPartition :: Disk -> Partition -> IO ()
addPartition disk partition = do
    _ <- parted device ["rm", "1"]
    _ <- parted device ["mkpart", "primary", "fat32", start1, end1]
    _ <- parted device ["mkpart", "primary", fs2,     start2, end2]
    _ <- parted device ["set", "2", "boot", "on"]
    _ <- parted device ["set", "2", "hidden", "on"]
    mkfs (device ++ "1") "vfat" ["-F", "32", "-n", "WINDATA"]
    addPersistence $ device ++ "1"
    where device = devicePath disk
          start1 = show $ (partEnd partition) + 1
          end1   = show $ (diskSize disk) - 1
          start2 = show $ partStart partition
          end2   = show $ partEnd partition
          fs2    = fileSystem partition


parted:: String -> [String] -> IO String
parted device args =
    readProcess "/sbin/parted" (["-s", "-m", device, "unit", "s"] ++ args) ""

mkfs:: String -> String -> [String] -> IO ()
mkfs device fsType args =
    void $ readProcess "/sbin/mkfs" (["-t", fsType] ++ args ++ [device]) ""

addPersistence :: String -> IO ()
addPersistence device = do
    mkdir ["-p", "./.mnt"]
    mount [device, "./.mnt"]
    dd ["if=/dev/null", "bs=1", "count=0", "seek=1G", "of=./.mnt/persistence"]
    mkfs "./.mnt/persistence" "ext4" ["-F"]
    mkdir ["-p", "./.mnt2"]
    mount ["-t", "ext4", "./.mnt/persistence", "./.mnt2"]
    writeFile "./.mnt2/persistence.conf" "/home union\n"
    umount ["./.mnt2"]
    umount ["./.mnt"]
    return ()
    where mount  args = void $ readProcess "/bin/mount"  args ""
          umount args = void $ readProcess "/bin/umount" args ""
          dd     args = void $ readProcess "/bin/dd" args ""
          mkdir  args = void $ readProcess "/bin/mkdir" args ""

data Partition = Partition { partNumber :: Int
                           , partStart  :: Integer
                           , partEnd    :: Integer
                           , fileSystem :: String
                           } deriving (Show)

data Disk = Disk { devicePath     :: String
                 , diskSize       :: Integer
                 , partitionTable :: String
                 } deriving (Show)

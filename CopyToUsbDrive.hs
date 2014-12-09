-- usage: runhaskell CopyToUsbDrive.hs live-image.iso /dev/sdX
--
-- This will copy the live-image.iso to your USB thumb drive. It will further
-- add a partition on your bootable USB thumb drive that can be used by
-- Windows. Therefore it will first remove the existing Live-Linux partition
-- then create a new partition behind the Live-Linux partition. And then will
-- recreate the Live-Linux partition with the same geometry as before.
--
-- The resulting layout looks something like this:
--   sdx2  live-linux   ---    (size of live-image.iso)
--   sdx3  persistence  ext4   ~ 1 GB
--   sdx1  windata      fat32  (the remaining space)

import Control.Applicative   ((<$>))
import Control.Monad         (void, when)
import Data.String.Utils     (split)
import System.Environment    (getArgs)
import System.Process        (readProcess)

main :: IO ()
main = do
    [iso, device] <- getArgs
    putStrLn $ "This will overwrite all data on " ++ device ++ "!"
    putStrLn "Do you really want to continue? yes/[no]"
    isOk <- getLine
    when (isOk /= "yes") $ error "aborted by user"
    putStrLn "Copy image to device ..."
    dd iso device
    sync
    putStrLn "Create extra partitions ..."
    (disk, partitions) <- getDiskLayout device
    addPartition disk $ partitions !! 0
    putStrLn "Done!"
    where
        dd iso device =
            void $ readProcess "/bin/dd"
                ["bs=4096", "if=" ++ iso ,"of=" ++ device] ""
        sync = void $ readProcess "/bin/sync" [] ""

getDiskLayout:: String -> IO (Disk, [Partition])
getDiskLayout device = do
    out <- map (split ":") <$> lines <$> parted device ["print"]
    return ( toDisk $ out !! 1
           , map toPart $ drop 2 out
           )
    where
        readS a
            | last a == 's' = read $ init a
        toPart (number : start : end : _ : fs : _) =
            Partition (read number) (readS start) (readS end) fs
        toDisk (_ : secCnt : _ : secSize : _ : partTable : _) =
            Disk device (readS secCnt) (read secSize) partTable

addPartition :: Disk -> Partition -> IO ()
addPartition disk partition = do
    when toSmall $ error "error: target device to small"
    _ <- parted device ["rm", "1"]
    _ <- parted device ["mkpart", "primary", "fat32", show start1, show end1]
    _ <- parted device ["mkpart", "primary", fs2,     show start2, show end2]
    _ <- parted device ["mkpart", "primary", "ext4",  show start3, show end3]
    _ <- parted device ["set", "2", "boot", "on"]
    _ <- parted device ["set", "2", "hidden", "on"]
    mkfs (device ++ "1") "vfat" ["-F", "32", "-n", "WINDATA"]
    mkfs (device ++ "3") "ext4" ["-L", "persistence"]
    addPersistence $ device ++ "3"
    where
        device = devicePath disk
        start2 = partStart partition
        end2   = partEnd partition
        start3 = end2 + 1
        end3   = start3 + (10^9 `quot` (sectorSize disk))
        start1 = end3 + 1
        end1   = (sectorCount disk) - 1
        fs2    = fileSystem partition
        toSmall = (end1 - start1) < (10^7 `quot` (sectorSize disk))


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
    writeFile "./.mnt/persistence.conf" "/home union\n"
    umount ["./.mnt"]
    where
        mount  args = void $ readProcess "/bin/mount"  args ""
        umount args = void $ readProcess "/bin/umount" args ""
        mkdir  args = void $ readProcess "/bin/mkdir" args ""

data Partition = Partition { partNumber :: Int
                           , partStart  :: Integer
                           , partEnd    :: Integer
                           , fileSystem :: String
                           } deriving (Show)

data Disk = Disk { devicePath     :: String
                 , sectorCount    :: Integer
                 , sectorSize     :: Integer
                 , partitionTable :: String
                 } deriving (Show)

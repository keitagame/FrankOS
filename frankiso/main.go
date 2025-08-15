package main

import (
    "fmt"
    "os"
    "os/exec"

    "github.com/spf13/cobra"
    "gopkg.in/yaml.v3"
)

type Profile struct {
    Arch     string   `yaml:"arch"`
    Base     struct {
        Mirror     string `yaml:"mirror"`
        PacmanConf string `yaml:"pacman_conf"`
    } `yaml:"base"`
    Packages []string `yaml:"packages"`
    Artifacts struct {
        IsoName string `yaml:"iso_name"`
    } `yaml:"artifacts"`
}

func main() {
    var (
        profileFile string
        outDir      string
    )

    rootCmd := &cobra.Command{Use: "frankiso"}
    buildCmd := &cobra.Command{
        Use:   "build",
        Short: "プロファイルから ISO をビルド",
        RunE: func(cmd *cobra.Command, args []string) error {
            // 1) プロファイル読み込み
            data, err := os.ReadFile(profileFile)
            if err != nil {
                return err
            }
            var p Profile
            if err := yaml.Unmarshal(data, &p); err != nil {
                return err
            }

            // 2) rootfs 作成 (pacstrap 相当)
            os.MkdirAll(outDir+"/rootfs", 0755)
            fmt.Println("==> Creating rootfs")
            iargs := append([]string{"pacstrap", "-c", "-d", outDir + "/rootfs"}, p.Packages...)
            c1 := exec.Command( iargs...)

            c1.Stdout = os.Stdout
            c1.Stderr = os.Stderr
            if err := c1.Run(); err != nil {
                return err
            }

            // 3) ISO 生成 (xorriso で簡易)
            isoPath := outDir + "/" + p.Artifacts.IsoName
            fmt.Println("==> Generating ISO:", isoPath)
            c2 := exec.Command("xorriso", "-as", "mkisofs", "-o", isoPath, "-J", "-R", outDir+"/rootfs")
            c2.Stdout = os.Stdout
            c2.Stderr = os.Stderr
            return c2.Run()
        },
    }

    buildCmd.Flags().StringVarP(&profileFile, "profile", "p", "", "YAML プロファイルパス")
    buildCmd.Flags().StringVarP(&outDir, "output", "o", "dist", "出力ディレクトリ")
    buildCmd.MarkFlagRequired("profile")
    rootCmd.AddCommand(buildCmd)

    if err := rootCmd.Execute(); err != nil {
        os.Exit(1)
    }
}

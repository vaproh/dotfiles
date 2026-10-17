import { spawnSync } from "node:child_process"

function execSync(cmd: string, args: string[]): { stdout: string } | null {
  try {
    const r = spawnSync(cmd, args, { encoding: "utf-8" })
    if (r.status === 0) return { stdout: r.stdout ?? "" }
    return null
  } catch { return null }
}

export default {
  id: "rtk",
  async setup(ctx: any) {
    const hasRtk = execSync("which", ["rtk"])
    if (!hasRtk) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }
    await ctx.tool.hook("execute.before", async (event: any) => {
      const tool = String(event?.tool ?? event?.input?.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const args = event?.input ?? event?.output?.args ?? event?.args
      if (!args || typeof args !== "object") return
      const command = (args as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return
      try {
        const result = spawnSync("rtk", ["rewrite", command], { encoding: "utf-8" })
        if (result.status !== 0) return
        const rewritten = String(result.stdout ?? "").trim()
        if (rewritten && rewritten !== command) {
          ;(args as Record<string, unknown>).command = rewritten
        }
      } catch {}
    })
  },
}

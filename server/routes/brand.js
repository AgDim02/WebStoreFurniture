import express from 'express'
import BrandController from '../controllers/Brand.js'
import authMiddleware from '../middleware/authMiddleware.js'
import adminMiddleware from '../middleware/adminMiddleware.js'

const router = new express.Router()

router.get('/getAll', BrandController.getAll)
router.get('/getOne/:id([0-9]+)', BrandController.getOne)
router.post('/create', authMiddleware, adminMiddleware, BrandController.create)
router.put('/update/:id([0-9]+)', authMiddleware, adminMiddleware, BrandController.update)
router.delete('/delete/:id([0-9]+)', authMiddleware, adminMiddleware, BrandController.delete)

export default router